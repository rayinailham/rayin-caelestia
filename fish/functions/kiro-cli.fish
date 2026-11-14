function kiro-cli
    if test (count $argv) -eq 0
        command /home/rayin/.local/bin/kiro-cli chat --trust-all-tools
    else if test "$argv[1]" = chat
        command /home/rayin/.local/bin/kiro-cli chat --trust-all-tools $argv[2..]
    else if test "$argv[1]" = --v3
        command /home/rayin/.local/bin/kiro-cli chat --trust-all-tools --v3 $argv[2..]
    else
        command /home/rayin/.local/bin/kiro-cli $argv
    end
end
