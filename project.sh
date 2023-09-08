#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash figlet tmux

# Session Name
session="project-env-sh"

# Check if the session exists, discarding output
# We can check $? for the exit status (zero for success, non-zero for failure)
tmux has-session -t $session 2>/dev/null

if [ $? != 0 ]; then
	# Start New Session with our name
	tmux new-session -d -s $session

	# Name first Window and start zsh
	tmux rename-window -t 0 'Main'
	tmux send-keys -t 'Main' 'nix flake show' C-m
	tmux send-keys -t 'Main' 'clear' C-m

	# Create and setup pane for btop
	tmux split-window -h
	tmux rename-window 'btop'
	tmux send-keys -t 'btop' 'ssh -t commander@193.16.42.125 btop' C-m

	tmux select-pane -t 0

	# Create and setup pane for btop
	tmux split-window -v
	tmux rename-window 'ssh'
	tmux send-keys -t 'ssh' 'ssh commander@193.16.42.125' C-m

	tmux select-pane -t 0
fi
tmux attach-session -t $session
