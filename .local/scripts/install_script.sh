#!/bin/bash
export SHELL=/bin/bash
export AUR_HELPER=paru
if command -v flatpak 2>&1 >/dev/null; then
    parf_flatpak_repos=()
    parf_per_user=()
    parf_cache_dir="/tmp/pacall_cache"
    \mkdir -p "$parf_cache_dir" || return 1

    parf_flatpak_repos=($(flatpak --user remotes | awk '{print $1}'))

    if [ -z "$parf_flatpak_repos" ]; then
        parf_flatpak_repos=($(flatpak --system remotes | awk '{print $1}'))
        parf_per_user=0
    else
        parf_per_user=1
    fi
fi


parf_fzf_preview()
{
    local package="${*//\*/}"
    local repo=""

    # find longest matching repo name
    for r in "${parf_flatpak_repos[@]}"; do
        if [[ "$package" == *"-$r" && ${#r} -gt ${#repo} ]]; then
            repo="$r"
        fi
    done

    if [[ -n "$repo" ]]; then
        package="${package%-"$repo"}"
        package="${package##*\(}" # remove everything before last (
        package="${package%%\)*}" # remove everything after last )

        if [[ "$parf_per_user" -eq 1 ]]; then
            flatpak --user remote-info "$repo" "$package" | tail -n +2
        else
            flatpak --system remote-info "$repo" "$package" | tail -n +2
        fi
    else
        echo "$package" >> /tmp/packages_preview.txt
        $AUR_HELPER -Si "$package"
    fi
}

parfs()
{
    if [[ -z "$parf_flatpak_repos" && -z "$parf_per_user" ]]; then
        echo "Flatpak not installed."
        return 1
    fi

    {
        $AUR_HELPER -Sl | awk '{s=$2; gsub(/\x1b\[[0-9;]*m/, "", s); print s ($4 == "" ? "" : "*")}'
        for repo in "${parf_flatpak_repos[@]}"; do
            local cache_file="$parf_cache_dir/$repo.cache"
            if [[ ! -f "$cache_file" || $(find "$cache_file" -mmin +60) ]]; then
                local flatpak_packages=""
                local flatpak_packages_installed=""
                if [ "$parf_per_user" -eq 1 ]; then
                    flatpak_packages=$(flatpak --user remote-ls --app --columns=name,application "$repo")
                    flatpak_packages_installed=$(flatpak --user list --app --columns=name,application)
                else
                    flatpak_packages=$(flatpak --system remote-ls --app --columns=name,application "$repo")
                    flatpak_packages_installed=$(flatpak --system list --app --columns=name,application)
                fi
                awk -F'\t' -v r="$repo" '
                NR==FNR { lookup[$2] = 1; next }
                { printf "%s(%s)-%s%s\n", $1, $2, r, ($2 in lookup ? "*" : "")}
                ' <(echo "$flatpak_packages_installed") <(echo "$flatpak_packages") >"$cache_file"
            fi
            cat "$cache_file"
        done
    } | fzf --multi --preview '
            '"$(declare -p parf_flatpak_repos)"'
            '"$(declare -f parf_fzf_preview)"'
            '"$(declare -p parf_per_user)"'
            parf_fzf_preview {}
    ' | tr -d "*"
}
