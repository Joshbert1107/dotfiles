function sysupdate --description 'System updatewith confirmation after reading Arch News. Updates pacman/paru/flatpak.'
    paru -Pw
    confirm; or return 1
    paru -Syu --batchinstall --combinedupgrade
    flatpak update --assumeyes
end
