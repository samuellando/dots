if status is-interactive
    set fish_greeting
    fish_vi_key_bindings
    set fish_cursor_default block
    set fish_cursor_insert line
    set -x GOPATH $HOME/go
    set -x PATH $PATH $GOPATH/bin

    function envsource
      for line in (cat $argv | grep -v '^#' | grep -v '^\s*$')
        set item (string split -m 1 '=' $line)
        set -gx $item[1] $item[2]
        echo "Exported key $item[1]"
      end
    end

    function fish_prompt
        set -l last_status $status
        if test $last_status -ne 0
            set prompt_status (set_color red)"O_O"(set_color normal)
        else
            set prompt_status (set_color green)"^_^"(set_color normal)
        end
        string join '' " " (set_color purple) (prompt_pwd) (set_color blue) (fish_git_prompt) " " $prompt_status (set_color purple) ' $ ' (set_color normal)
    end

    # Capture the start time before a command runs
    function start_timer --on-event fish_preexec
        set -g __start_time (date +%s.%N)
    end

    # Calculate and display the execution time after the command finishes
    function set_execution_time --on-event fish_postexec
        if test -n "$__start_time"
            set -l end_time (date +%s.%N)
            set -g __exec_time (math $end_time - $__start_time)
        else
            set -g __exec_time ""
        end
    end

    # Define the right prompt to show the execution time
    function fish_right_prompt
        if test -n "$__exec_time"
            printf "⏱ %.2f s  " $__exec_time
        end
    end

    function right_time --on-event fish_preexec
        set -l current_time (date '+%H:%M:%S')
        set -l C (math $COLUMNS - 10)
        printf "\033[1A\033[%dC%s\n" $C $current_time
    end

    function fish_mode_prompt
      echo -n ""
    end

    alias vim=nvim
    alias tmux='tmux -u'
    alias ls="ls --color=auto"
    alias clear=clear; fetch

    # Source the .fishrc file from the home directory
    if test -f $HOME/.fishrc.fish
        source $HOME/.fishrc.fish
    end
end
