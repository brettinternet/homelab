#!/usr/bin/env bash
# Rotate the SOPS age key.
#
# 1. Generate a new age keypair next to the current key file.
# 2. Swap the recipient in .sops.yaml.
# 3. For every tracked SOPS file: updatekeys (new recipient only), then rotate
#    (fresh data key, so the old age key can't unwrap new ciphertext).
# 4. Verify every file decrypts with the new key to identical plaintext.
# 5. Install the new key and keep the old one as a timestamped backup.
#
# Nothing is committed. On failure, restore with:
#   git checkout -- .sops.yaml <sops files>
set -euo pipefail

root_dir="$(git rev-parse --show-toplevel)"
key_file="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"
new_key_file="$key_file.new"
config_file="$root_dir/.sops.yaml"

cd "$root_dir"

die() {
  echo "error: $*" >&2
  exit 1
}

for cmd in sops age-keygen git shasum perl; do
  command -v "$cmd" >/dev/null || die "missing $cmd"
done

[ -f "$key_file" ] || die "no key file at $key_file"
[ -e "$new_key_file" ] && die "$new_key_file already exists; remove it or finish a previous run"

old_pub="$(age-keygen -y "$key_file")"
[ "$(printf '%s\n' "$old_pub" | wc -l)" -eq 1 ] || die "$key_file must contain exactly one identity"
grep -qF "$old_pub" "$config_file" || die "$old_pub not found in .sops.yaml"

files=()
while IFS= read -r f; do
  files+=("$f")
done < <(git ls-files -- '*.sops.yaml' '*.sops.yml' '*sops.env' | grep -v '^\.sops\.yaml$')
[ "${#files[@]}" -gt 0 ] || die "no SOPS files found"

git diff --quiet HEAD -- "$config_file" "${files[@]}" ||
  die "uncommitted changes in SOPS files or .sops.yaml; commit or stash first"

before=()
for f in "${files[@]}"; do
  grep -q 'ENC\[AES256_GCM' "$f" || die "$f is not encrypted"
  before+=("$(SOPS_AGE_KEY_FILE="$key_file" sops decrypt "$f" | shasum -a 256)") ||
    die "current key cannot decrypt $f"
done

echo "Current recipient: $old_pub"
echo "Files:"
printf '  %s\n' "${files[@]}"
read -rp "Rotate? [y/N] " answer
[ "$answer" = y ] || [ "$answer" = Y ] || die "aborted"

(
  umask 077
  age-keygen -o "$new_key_file" 2>/dev/null
)
new_pub="$(age-keygen -y "$new_key_file")"
echo "New recipient: $new_pub"

perl -pi -e "s/\Q$old_pub\E/$new_pub/g" "$config_file"

for f in "${files[@]}"; do
  echo "Re-encrypting $f"
  SOPS_AGE_KEY_FILE="$key_file" sops updatekeys --yes "$f"
  SOPS_AGE_KEY_FILE="$new_key_file" sops rotate --in-place "$f"
done

for i in "${!files[@]}"; do
  f="${files[$i]}"
  grep -qF "$old_pub" "$f" && die "$f still lists the old recipient"
  after="$(SOPS_AGE_KEY_FILE="$new_key_file" sops decrypt "$f" | shasum -a 256)"
  [ "$after" = "${before[$i]}" ] || die "$f plaintext changed after rotation"
done

backup="$key_file.$(date +%Y%m%d%H%M%S).old"
mv "$key_file" "$backup"
mv "$new_key_file" "$key_file"

cat <<EOF

Rotation complete. All ${#files[@]} files verified against the new key.

Next:
  1. Back up $key_file to your password manager / offline copy.
  2. Review and commit: git diff --stat
  3. Rotate the actual secret values if the old key may have leaked;
     old ciphertext in git history still opens with the old key.
  4. Once committed and backed up: trash $backup
EOF
