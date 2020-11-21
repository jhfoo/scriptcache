# meta installer
cd ~
echo Installing tmux scripts >&1
curl https://raw.githubusercontent.com/jhfoo/scriptcache/master/tmux/install.sh | zsh
echo Installing .zshrc >&1
cd ~
curl -O https://raw.githubusercontent.com/jhfoo/scriptcache/master/.zshrc
cat .zshrc | source /dev/stdin
