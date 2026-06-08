# rayin-caelestia

My personal rice, a fork of the [caelestia](https://github.com/caelestia-dots)
dots tuned for my laptop. Hyprland on Arch (CachyOS), with the Caelestia
Quickshell shell and a set of app configs.

This repo contains the user configs plus an install script that symlinks
everything into place.

## My setup

-   **OS:** CachyOS (Arch-based)
-   **Compositor:** Hyprland (Wayland)
-   **Shell/bar:** Caelestia (Quickshell)
-   **GPU:** Hybrid Intel TigerLake-H UHD (iGPU) + NVIDIA RTX 3060 Laptop
-   **Panel:** eDP-1, 2560x1440 @ 165Hz (wired to the Intel iGPU)
-   **Terminal:** foot · **Shell:** fish · **Browser:** Zen

> [!NOTE]
> The internal panel is wired to the Intel iGPU, so the desktop and all
> native Wayland rendering run on Intel. The NVIDIA dGPU is used per-app via
> `prime-run` only. Do not force global NVIDIA env vars (`GBM_BACKEND`,
> `__GLX_VENDOR_LIBRARY_NAME`, etc.) or the internal display gets choppy.

## Performance tuning (165Hz)

This fork is tuned to actually hit ~160 FPS on the internal panel instead of
being stuck around 60-78 FPS. If you reuse these dots on different hardware,
review these first.

Config-level changes (already in this repo):

-   `hypr/variables.conf`: blur disabled, window opacity set to `1.0` to cut
    compositor work.
-   `hypr/hyprland/env.conf`: removed global NVIDIA forcing so the panel stays
    on Intel.
-   `quickshell/caelestia/modules/background/GifCorner.qml`: the animated
    corner gif was forcing poor frame pacing as a full-size layer surface. It
    is now smaller (160x160), slower (`speed 0.35`), decoded at display size
    (`sourceSize`), and `asynchronous` + `cache` enabled.
-   `caelestia/shell.json`: dashboard layer disabled.

System-level change (NOT in this repo, machine-specific):

> [!IMPORTANT]
> The single biggest win was disabling Intel Panel Self Refresh. Add
> `i915.enable_psr=0` to the kernel command line (for me, in
> `/boot/limine.conf`). This lives outside the repo, so reapply it manually
> after a reinstall. Do **not** also disable FBC/DC (`i915.enable_fbc=0`,
> `i915.enable_dc=0`); in testing those made pacing worse.

Quick checks if FPS regresses:

```sh
cat /proc/cmdline                       # expect i915.enable_psr=0
hyprctl monitors all                    # expect eDP-1 ... @165, hardwareCursorsInUse: true
weston-simple-egl                       # native Wayland frame pacing sample
hyprctl layers                          # watch for heavy fullscreen layer surfaces
```

## Installation

Clone the repo and run the install script (needs
[`fish`](https://github.com/fish-shell/fish-shell)).

> [!WARNING]
> The install script symlinks all configs into place, so you CANNOT
> move/remove the repo folder once you run it. If you do, most apps will
> misbehave and some (e.g. Hyprland) will fail to start. Clone to
> `~/.local/share/caelestia`.

```
$ ./install.fish -h
usage: ./install.sh [-h] [--noconfirm] [--spotify] [--vscode] [--discord] [--aur-helper]

options:
  -h, --help                  show this help message and exit
  --noconfirm                 do not confirm package installation
  --spotify                   install Spotify (Spicetify)
  --vscode=[codium|code]      install VSCodium (or VSCode)
  --discord                   install Discord (OpenAsar + Equicord)
  --zen                       install Zen browser
  --aur-helper=[yay|paru]     the AUR helper to use
```

For example:

```sh
git clone https://github.com/rayinailham/rayin-caelestia.git ~/.local/share/caelestia
~/.local/share/caelestia/install.fish
```

### Manual installation

Dependencies:

-   hyprland
-   xdg-desktop-portal-hyprland
-   xdg-desktop-portal-gtk
-   hyprpicker
-   wl-clipboard
-   cliphist
-   inotify-tools
-   app2unit
-   wireplumber
-   trash-cli
-   foot
-   fish
-   fastfetch
-   starship
-   btop
-   jq
-   eza
-   adw-gtk-theme
-   papirus-icon-theme
-   qtengine-git
-   ttf-jetbrains-mono-nerd

Install all dependencies and follow the installation guides of the
[shell](https://github.com/caelestia-dots/shell) and [cli](https://github.com/caelestia-dots/cli)
to install them.

> [!TIP]
> If on Arch or an Arch-based distro, there is a meta package available [in this repository](PKGBUILD)
> that pulls in all dependencies. It can be installed through the install script, makepkg/pacman, yay,
> paru, or your preferred AUR helper.

Then copy or symlink the `hypr`, `foot`, `fish`, `fastfetch`, `uwsm` and `btop` folders to the
`$XDG_CONFIG_HOME` (usually `~/.config`) directory. e.g. `hypr -> ~/.config/hypr`.
Copy `starship.toml` to `$XDG_CONFIG_HOME/starship.toml`.

#### Installing Spicetify configs:

Follow the Spicetify [installation instructions](https://spicetify.app/docs/advanced-usage/installation),
copy or symlink the `spicetify` folder to `$XDG_CONFIG_HOME/spicetify` and run

```sh
spicetify config current_theme caelestia color_scheme caelestia custom_apps marketplace
spicetify apply
```

#### Installing VSCode/VSCodium configs:

Install VSCode or VSCodium, then copy or symlink `vscode/settings.json` and
`vscode/keybindings.json` into the `$XDG_CONFIG_HOME/Code/User` (or `$XDG_CONFIG_HOME/VSCodium/User`
if using VSCodium) folder. Then copy or symlink `vscode/flags.conf` to `$XDG_CONFIG_HOME/code-flags.conf`
(or `$XDG_CONFIG_HOME/codium-flags.conf` if using VSCodium).

Finally, install the extension VSIX from `vscode/caelestia-vscode-integration`.

```sh
# Use `codium` if using VSCodium
code --install-extension vscode/caelestia-vscode-integration/caelestia-vscode-integration-*.vsix
```

#### Installing Zen Browser configs:

Install Zen Browser, then copy or symlink `zen/userChrome.css` to the `chrome` folder in your
profile of choice in `~/.zen`. e.g. `zen/userChrome.css -> ~/.zen/<profile>/chrome/userChrome.css`.

Now install the native app by copying `zen/native_app/manifest.json` to
`~/.mozilla/native-messaging-hosts/caelestiafox.json` and replacing the `{{ $lib }}` string in it
with the absolute path of `~/.local/lib/caelestia` (this must be the absolute path, e.g.
`/home/user/.local/lib/caelestia`). Then copy or symlink `zen/native_app/app.fish` to
`~/.local/lib/caelestia/caelestiafox`.

Finally, install the CaelestiaFox extension from [here](https://addons.mozilla.org/en-US/firefox/addon/caelestiafox).

## Updating

Run `yay` to update the AUR packages, then `cd` into the repo directory and run `git pull` to update the configs.

## Usage

> [!NOTE]
> These dots do not contain a login manager, so install one yourself unless
> you want to log in from a TTY. I recommend
> [`greetd`](https://sr.ht/~kennylevinsen/greetd) with
> [`tuigreet`](https://github.com/apognu/tuigreet), but any login manager works.

These are just dotfiles, so there aren't real usage instructions. Some useful
keybinds:

-   `Super` - open launcher
-   `Super` + `#` - switch to workspace `#`
-   `Super` `Alt` + `#` - move window to workspace `#`
-   `Super` + `T` - open terminal (foot)
-   `Super` + `W` - open browser (zen)
-   `Super` + `C` - open IDE (vscodium)
-   `Super` + `S` - toggle special workspace or close current special workspace
-   `Super` + `G` - toggle GitHub Desktop special workspace
-   `Super` + `/` - open the shortcuts helper
-   `Ctrl` `Alt` + `Delete` - open session menu
-   `Ctrl` `Super` + `Space` - toggle media play state
-   `Ctrl` `Super` `Alt` + `R` - restart the shell

## Credits

Based on the [caelestia-dots](https://github.com/caelestia-dots) project.
This is my personal fork with hardware-specific tuning and tweaks.
