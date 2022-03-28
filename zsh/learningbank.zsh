RESTORE='\033[0m'

RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
PURPLE='\033[00;35m'
CYAN='\033[00;36m'
LIGHTGRAY='\033[00;37m'

LRED='\033[01;31m'
LGREEN='\033[01;32m'
LYELLOW='\033[01;33m'
LBLUE='\033[01;34m'
LPURPLE='\033[01;35m'
LCYAN='\033[01;36m'
WHITE='\033[01;37m'

# Check for file changes and run a command
# https://davidwalsh.name/git-hook-npm-install-package-json-modified
check_run() {
    changed_files="$(git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD)"
	echo "$changed_files" | grep --quiet "$1" && eval "$2"
}

# Learningbank repository update script
# This will pull, migrate and npm install all microservices
# used by the frontend.
function lb() {
    if [ -z $1 ]; then 
        cd ~/Development/Learningbank && echo -e "\n${LYELLOW}Welcome to Learningbank 🎉 ${RESTORE}\n"
    elif [ $1 = 'start' ]; then
        tmuxinator start learningbank -p ~/dotfiles/tmuxinator/learningbank.yml
    elif [ $1 = 'stop' ]; then
        tmux kill-session -t learningbank
    elif [ $1 = 'update' ]; then
        # Save current location
        current_pwd=$(pwd)

        echo -e "\n🔐 ${LCYAN}Updating Auth Service..${RESTORE}\n"
        cd ~/Development/Learningbank/auth-service
        git pull --ff-only
        check_run package.json "npm ci"
        npm run db:up

        echo -e "\n🎛  ${LCYAN}Updating API Service..${RESTORE}\n"
        cd ~/Development/Learningbank/api-service
        git pull --ff-only
        check_run package.json "npm ci"
        npm run db:up

        echo -e "\n⚙️  ${LCYAN}Updating Hostconfig Service..${RESTORE}\n"
        cd ~/Development/Learningbank/hostconfig-service
        git pull --ff-only
        check_run package.json "npm ci"
        npm run db:up

        echo -e "\n📨 ${LCYAN}Updating Mail Service..${RESTORE}\n"
        cd ~/Development/Learningbank/mail-service
        git pull --ff-only
        check_run package.json "npm ci"
        npm run db:up

        echo -e "\n📙 ${LCYAN}Updating Resource Service..${RESTORE}\n"
        cd ~/Development/Learningbank/resource-service
        git pull --ff-only
        check_run package.json "npm ci"
        npm run db:up

        # Navigate back to location where script was fired from.
        cd "$current_pwd"

        echo -e "\n${LYELLOW}You are all set!${RESTORE} 👍 \n"

    else
       echo "Unknown parameter '$1'"
    fi
}