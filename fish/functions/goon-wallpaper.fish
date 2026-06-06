function goon-wallpaper --description "Switch to a random wallpaper from the goon-wallpapers folder, or set a specific one"
    if test (count $argv) -gt 0
        set -l wall_path ~/Pictures/goon-wallpapers/$argv[1]
        if test -f $wall_path
            caelestia wallpaper -f $wall_path
        else if test -f $argv[1]
            caelestia wallpaper -f $argv[1]
        else
            echo "Wallpaper not found: $argv[1]"
        end
    else
        caelestia wallpaper -n -r ~/Pictures/goon-wallpapers
    end
end
