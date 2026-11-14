function browser --description 'Browser Use prompt agent via local 9router'
    if not isatty stdin
        command browser-use $argv
        return $status
    end

    if test (count $argv) -eq 0
        command browser-use
        return $status
    end

    switch $argv[1]
        case --help --version --doctor doctor auth telemetry skill --update --reload
            command browser-use $argv
            return $status
    end

    set -l task (string join ' ' -- $argv)
    if test "$task" = "."
        read -P 'browser task> ' task
    end

    if test -z "$task"
        echo 'Usage: browser "open example.com and summarize it"'
        return 2
    end

    browser-agent-9router "$task"
end
