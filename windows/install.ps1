if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Scoop not found. Installing..." -ForegroundColor Cyan
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
} else {
    Write-Host "Scoop is already installed." -ForegroundColor Green
}

scoop install git 
scoop bucket add extras 
scoop bucket add nerd-fonts 
scoop install Cascadia-Code
scoop install neovim btop nodejs alacritty wcurl cygwin helium glazewm zebar windhawk 

Move-Item $env:LOCALAPPDATA\nvim $env:LOCALAPPDATA\nvim.bak

Move-Item $env:LOCALAPPDATA\nvim-data $env:LOCALAPPDATA\nvim-data.bak
git clone https://github.com/LazyVim/starter $env:LOCALAPPDATA\nvim
Remove-Item $env:LOCALAPPDATA\nvim\.git -Recurse -Force

#$profilePath = $env:USERPROFILE -replace '\\', '/'; $config = "`n`n[terminal.shell]`nprogram = ""$profilePath/scoop/shims/bash.exe""`nargs = [""--login""]"; Set-Content -Path "$env:APPDATA\alacritty\alacritty.toml" -Value $config -Encoding utf8

alacritty
