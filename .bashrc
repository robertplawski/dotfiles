# .bashrc
alias vim='nvim'
# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

if [ -z "$XDG_RUNTIME_DIR" ]; then
  export XDG_RUNTIME_DIR=/run/user/$(id -u)
fi
export WEBKIT_DISABLE_COMPOSITING_MODE=1

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
  PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH
export PATH=/usr/local/cuda-12.6/bin${PATH:+:${PATH}}
export OLLAMA_HOST="0.0.0.0:11434"
export QT_QPA_PLATFORM=wayland
if [ -d "$HOME/.local/bin" ]; then
  PATH="$HOME/.local/bin:$PATH"
fi
#export CUDA_HOME=/usr/local/cuda
#xport PATH=${CUDA_HOME}/bin:${PATH}
#export LD_LIBRARY_PATH=${CUDA_HOME}/lib64:$LD_LIBRARY_PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
  for rc in ~/.bashrc.d/*; do
    if [ -f "$rc" ]; then
      . "$rc"
    fi
  done
fi
unset rc
. "$HOME/.cargo/env"
