# If you come from bash you might have to change your $PATH.
#
#export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="essembeh"

plugins=(git
  wp-cli
  zsh-autosuggestions
  zsh-syntax-highlighting
  web-search
)

ZSH_WEB_SEARCH_ENGINES=(reddit "https://old.reddit.com/search/?q=")

alias vim="nvim"
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# flatpak shortened aliases
~/.config/scripts/flatpak-aliases.sh
source ~/.config/flatpak_aliases.txt

# fixed gtk webview apps
export WEBKIT_DISABLE_DMABUF_RENDERER=1
export QT_QPA_PLATFORM=xcb

# cuda
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/xrt/lib:/usr/xrt/lib64:$LD_LIBRARY_PATH

#cargo
export PATH=/home/robert/.cargo/bin:$PATH
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# starship
eval "$(starship init zsh)"

# Turso
export PATH="$PATH:/home/robert/.turso"

#ytmpv
ytmpv () {
  local v_id=$1
  local b_url="https://www.youtube.com/watch?v=$v_id"
  local f_url
  f_url=$(yt-dlp --proxy http://127.0.0.1:38888 -f 'best[ext=mp4]' -g "$b_url")
  if [[ -z "$f_url" ]]; then
      echo "❌ Failed to fetch stream. Check yt-dlp or proxy."
      return 1
  fi
  mpv --quiet --http-proxy=http://127.0.0.1:38888 "$f_url" > /dev/null 2>&1
}
