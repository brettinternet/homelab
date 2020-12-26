# Setup

## Packages

[Install from a list](https://wiki.archlinux.org/index.php/Pacman/Tips_and_tricks#List_of_installed_packages):

```sh
pacman -S --needed - < packages/base.txt
```

exclude `#` if any:

```sh
grep -v "^#" pkg-list.txt | pacman -S --needed -

sed -e "/^#/d" -e "s/#.*//" packages.txt | pacman -S --needed -
```

### AUR

Install [yay](https://github.com/Jguer/yay) (or you may consider using aurutils with [aurto](https://github.com/alexheretic/aurto) instead)

```sh
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si
```

Build and install AUR packages with yay

```sh
yay -S - < packages/aur.txt
```

### Other

- [zinit](https://github.com/zdharma/zinit); afterwards, run `zsh` once to setup plugins before logging out/in

## Configuration

### Workspaces

Since I use the same dotfiles across multiple workspaces, local environment variables specific to a workspace and not added to source control are add to `$HOME/.env` and imported into the environment. See [.env.example](../configs/.env.example) for details.

### Power Management

#### Console

Since I don't use a display manager, it may be practical to implement power settings for the console login screen. `cat /sys/module/kernel/parameters/consoleblank` with an output of `0` suggests no `consoleblank`ing is occurring and the login screen will not timeout. Add a kernel parameter of `consoleblank=600` to timeout after 10 minutes with a console screensaver.

#### Laptops

- [TLP](https://wiki.archlinux.org/index.php/TLP)

#### Hibernation

[Setup hibernation](https://wiki.archlinux.org/index.php/Power_management/Suspend_and_hibernate#Hibernation) - don't forget to re-generate the grub.cfg (`grub-mkconfig -o /boot/grub/grub.cfg`) and initramfs (`mkinitcpio -p linux`)

#### [Laptops](https://wiki.archlinux.org/index.php/Laptop_Mode_Tools)

### Input

- [Logitech MX Master](https://wiki.archlinux.org/index.php/Logitech_MX_Master)
- [Mouse Acceleration](https://wiki.archlinux.org/index.php/Mouse_acceleration)

#### Laptops

- [TouchPad Synaptics](https://wiki.archlinux.org/index.php/Touchpad_Synaptics)
  - [TouchPad remapping note](https://wiki.archlinux.org/index.php/Libinput#Manual_button_re-mapping)

### Display

#### Laptops

- [Backlight](https://wiki.archlinux.org/index.php/Backlight#xbacklight)
