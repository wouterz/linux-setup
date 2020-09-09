#! /bin/bash

# Parameters
OS=$(tr [A-Z] [a-z] <<< $(uname -rv))
SHELL=${1:-zsh}

# vim
cp .vimrc ~/.vimrc

## Oh-My-Shell
#if [ $SHELL = "zsh" ]
#then
#    cp .zshrc ~/.zshrc
#    wget -nv https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
#    sh install.sh --ship-chsh
#    rm ./install.sh
#elif [ $SHELL = "fish" ]
#then
#    sh -c 'curl -L https://get.oh-my.fish | fish'
#fi
# 
#sudo chsh -s $(which $SHELL)

# Force sudo
if [ $EUID != 0 ]
then
    sudo "$0" "$@"
    exit $?
fi

# Install command
if [[ $OS == *"ubuntu"* ]]
then
    TMP="sudo apt-get install -y"
elif [[ $OS == *"manjaro"* ]]
then
    TMP="yes | sudo pacman -S"
else
    echo "No setup for this OS: '$OS'"
    exit 1
fi

# Packages to install
ProgramArray=("git" "vim" "curl" "wget" $SHELL 'python3' 'python3-pip' 'guake' 'tmux' 'docker-compose' 'fasd')
for program in ${ProgramArray[*]}; do
    sh -c "$TMP $program"
done

python3 -m pip install --upgrade pip
python3 -m pip install thefuck

echo '# Start libs' >> ~/.bashrc
echo 'eval $(fasd --init auto)' >> ~/.bashrc
echo 'eval $(thefuck --alias)' >> ~/.bashrc

# Backup evdev
EVDEV=/usr/share/X11/xkb/keycodes/evdev
# Backup original, then switch caps and F12 codes (66/96)
sudo sed -i.bak -r 's/\s66/_tmp_/g' $EVDEV
sudo sed -i -r 's/\s96/ 66/g' $EVDEV
sudo sed -i -r 's/_tmp_/ 96/g' $EVDEV
# Reload evdev for take changes into account
setxkbmap -layout us

# Clean up
sudo apt autoremove -y

echo "Run 'source ~/.bashrc' or start a new terminal to finish the setup"