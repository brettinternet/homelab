#!/usr/bin/env bash
# Re-encrypt every tracked SOPS file to the recipients in .sops.yaml.
#
# 1. Decrypt every file with the current identities and hash the plaintext.
# 2. rotate (fresh data key), then updatekeys (wrap it for exactly the
#    recipients in .sops.yaml, dropping any others).
# 3. Verify each file lists exactly those recipients and decrypts to
#    identical plaintext.
#
# Edit the recipient list in .sops.yaml first. Nothing is committed. On
# failure, restore with:
#   git checkout -- <sops files>
set -euo pipefail

root_dir="$(git rev-parse --show-toplevel)"
config_file="$root_dir/.sops.yaml"
recipient_re='age1[0-9a-z]{50,}'

cd "$root_dir"

die() {
  echo "error: $*" >&2
  exit 1
}

for cmd in sops git shasum; do
  command -v "$cmd" >/dev/null || die "missing $cmd"
done

files=()
while IFS= read -r f; do
  files+=("$f")
done < <(git ls-files -- '*.sops.yaml' '*.sops.yml' '*sops.env' | grep -v '^\.sops\.yaml$')
[ "${#files[@]}" -gt 0 ] || die "no SOPS files found"

git diff --quiet HEAD -- "${files[@]}" ||
  die "uncommitted changes in SOPS files; commit or stash first"

want="$(grep -oE "$recipient_re" "$config_file" | sort -u)"
[ -n "$want" ] || die "no age recipients in .sops.yaml"

before=()
for f in "${files[@]}"; do
  grep -q 'ENC\[AES256_GCM' "$f" || die "$f is not encrypted"
  echo "Decrypting $f"
  before+=("$(sops decrypt "$f" | shasum -a 256)") || die "cannot decrypt $f"
done

echo
echo "Recipients:"
printf '  %s\n' "$want"
echo "Files:"
printf '  %s\n' "${files[@]}"
read -rp "Rekey? [y/N] " answer
[ "$answer" = y ] || [ "$answer" = Y ] || die "aborted"

for f in "${files[@]}"; do
  echo "Re-encrypting $f"
  sops rotate --in-place "$f"
  sops updatekeys --yes "$f"
done

for i in "${!files[@]}"; do
  f="${files[$i]}"
  have="$(grep -oE "$recipient_re" "$f" | sort -u)"
  [ "$have" = "$want" ] || die "$f recipients do not match .sops.yaml"
  echo "Verifying $f"
  after="$(sops decrypt "$f" | shasum -a 256)"
  [ "$after" = "${before[$i]}" ] || die "$f plaintext changed after rekey"
done

cat <<EOF

Rekey complete. All ${#files[@]} files verified.

Old ciphertext in git history still opens with any removed key; rotate the
secret values themselves if a removed key may have leaked.
EOF
