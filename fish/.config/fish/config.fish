# Custom greeting
set fish_greeting "Hey, do you see something fishy?"

# Locale setting
set -x LC_ALL en_US.UTF-8
set -x LANG en_US.UTF-8

set -gx TERM "screen-256color"

# osx fix
if test -d "/usr/local/opt/coreutils/libexec/gnubin"
	set -gx PATH "/usr/local/opt/coreutils/libexec/gnubin" $PATH
end

# Golang settings
set -x GOPATH $HOME/workspace/golang
set -gx PATH $PATH $GOPATH/bin

# Python
# I cannot tell how much I hate this cached shit
set -gx PYTHONDONTWRITEBYTECODE true

# Virtualenv disable prompt
# set -x VIRTUAL_ENV_DISABLE_PROMPT "TRUE"

# Alias
alias ls="exa"
alias lt="exa --tree"
alias ll="ls -l"

# Fuzzy changing
alias fd="fzf-cd-widget"

# Bookmark manager
alias b="buku"

# TaskWarrior Aliases
alias in="task add +in"

# Virtualenv aliases
function switch_to_virtualenv
	test -d .venv
	if test $status -ne 0
		python -m venv .venv
	end
	source .venv/bin/activate.fish
end
alias v="switch_to_virtualenv"
alias V="deactivate"

# Custom watch
function watch
	while true
 		clear
 		eval $argv[2..-1]
 		sleep $argv[1]
 	end
end

function is_tmux
	if set -q TMUX
		return 0
	else
		return 1
	end
end

# Tmux shortcut
function setup_tmux
	set -l SESSION main

	tmux -2 new-session -d -s $SESSION -n 'mail'
	tmux send-keys "neomutt" C-m

	tmux new-window -t $SESSION:2 -n 'weechat'
	tmux send-keys "weechat" C-m

	tmux new-window -t $SESSION:3 -n 'tasks'
	setup_taskwarrior

	tmux new-window -t $SESSION:3 -n 'know'
	setup_know

	# Set default window
	tmux select-window -t $SESSION:1

	# Attach to session
	tmux -2 attach-session -t $SESSION
end

function setup_taskwarrior
	# Split pane vertically first
	tmux split-window -v -p 70
	# Select top pane and split it horizontally
	tmux select-pane -t 1
	tmux split-window -h -p 33
	tmux select-pane -t 1
	tmux send-keys "watch 300 task" C-m
	tmux select-pane -t 2
	tmux send-keys "watch 300 task summary" C-m
	# Switch to pane 1
	tmux select-pane -t 3
	tmux split-window -v -p 55
	tmux select-pane -t 3
	tmux send-keys "watch 300 task calendar" C-m
	tmux select-pane -t 4
end

function setup_know
	# Split pane vertically first
	tmux split-window -h -p 50
	# Select top pane and split it horizontally
	tmux select-pane -t 1
	tmux send-keys "watch 300 senjutsu hn -tnb -s 5" C-m
	tmux select-pane -t 2
	tmux send-keys "buku" C-m
end

function setup_jira
	# Split pane vertically first
	tmux split-window -v -p 60
	# Select top pane and split it horizontally
	tmux select-pane -t 2
	tmux split-window -v -p 60
	tmux select-pane -t 1
	tmux send-keys "watch 300 senjutsu jira -d open_sprint_tasks" C-m
	tmux select-pane -t 2
	tmux send-keys "watch 300 senjutsu jira -d pending_bug_tasks" C-m
	# Switch to pane 1
	tmux select-pane -t 3
	tmux send-keys "watch 300 senjutsu jira -d closed_sprint_tasks" C-m
end

function generate_image
	if test (count $argv) -lt 3
		echo "Usage: <command> widthxheigth fffffff filename"
	else
		convert -size $argv[1] xc:#$argv[2] $argv[3]
	end
end

# Processing helpers
alias to_str_json_array='awk \'BEGIN {printf "["} {printf t "\"%s\"",$0} {t=", "} END {printf "]"}\''
alias to_int_json_array='awk \'BEGIN {printf "["} {printf t $0} {t=", "} END {printf "]"}\''
alias to_jira_codefmt='awk \'BEGIN {printf "{code:theme=Midnight}\n"} { print $0 } END {printf "{code}\n"}\''

function jira_codefmt_file
	echo "{code:language=|title=$argv[1]|theme=Midnight}"
	cat $argv[1]
	echo "{code}"
end

if test -e ~/.custom.fish
	source ~/.custom.fish
end

# Kali helpers
alias kali='ssh -p 2222 root@localhost'