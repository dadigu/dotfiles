# Add global access to devkit
alias devkit='~/Development/Learningbank/devkit/devkit'

# Quick access learningbank development folder
function lb() {
    if [ -z $1 ]; then 
        cd ~/Development/Learningbank && echo -e "\nWelcome to Learningbank 🎉 \n"
    elif [ $1 = 'start' ]; then
        devkit start
    elif [ $1 = 'stop' ]; then
        devkit stop
    else
       cd ~/Development/Learningbank/"$1"
    fi
}
