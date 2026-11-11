function confirm
    while true
        read -l -P "Do you want to continue? [y/N] " answer
        switch $answer
            case Y y
                return 0
            case N n ''
                return 1
        end
    end
end
