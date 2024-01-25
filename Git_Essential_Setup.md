# Git Setup Script

This setup script automates the process of configuring a Git user, with useful settings like user credentials, default editor, CRLF handling, and SSH key authentication. Running the script will interactively prompt the user for values to put into the global Git configuration, enabling a full Git environment tailored for developers working on Linux machines connecting to remote repositories.

## Features

- Configures Git username and email 
- Sets default text editor for commit messages  
- Controls handling of CRLF/LF line endings
- Enables SSH key auth to services like GitHub/GitLab
- Automatically starts ssh-agent to load keys on login



## More Information

- CRLF refers to the Carriage Return Line Feed characters, handled differently by Linux vs Windows
- ssh-agent manages ssh keys for passwordless auth to remote git repos
- gitconfig controls per-user settings like author info, editor, line endings

Let me know if you need any other details in the README!



## Usage

The set-git-settings.sh script modifies the per-user ~/.gitconfig file. Run the script from your home directory:

```bash
./set-git-settings.sh
```

Follow the prompts to input your Git configurations. Default reasonable values are provided if needed.



This script is to verify git settings on Linux with inline documentation:

```
bash#!/bin/bash

# Script to verify and show important git config settings

# Display user name and email from global git config
echo "Git User Name:"
git config --global user.name 
echo
echo "Git User Email:"
git config --global user.email
echo

# List all global git configs
echo "Global Git Configs:"
git config --global --list
echo

# Show which git config file is being used for user.name
echo "Git Config File for User Name:"  
git config --show-origin user.name
echo

# Show core editor config
echo "Git Core Editor:"
git config --global core.editor
echo

# Show credential helper config
echo "Git Credential Helper:"
git config --global credential.helper
echo

# Check if system config file exists
if [ -f /etc/gitconfig ]; then
    echo "System Git Config:"
    cat /etc/gitconfig
else
    echo "No system gitconfig found"
fi

echo  
# Check if user config file exists
if [ -f ~/.gitconfig ]; then
    echo "User Git Config:"
    cat ~/.gitconfig
else
    echo "No user .gitconfig found"
fi
```

The script displays key git configurations, checks for system and user git config files, and prints them if they exist. Inline comments explain what each section is doing. This should help verify and troubleshoot git settings on Linux.



This script is to check if git user.name and user.email are set, and if not, prompts the user to input them and sets them in the global git config:

```
bash#!/bin/bash

# Script to verify and configure git settings

# Display user name 
echo "Git User Name:"
NAME=$(git config --global user.name)
if [ -z "$NAME" ]; then
    read -p "No git username set. Enter your name: " NAME
    git config --global user.name "$NAME"
else
  echo "$NAME"
fi
echo  

# Display user email
echo "Git User Email:"
EMAIL=$(git config --global user.email)
if [ -z "$EMAIL" ]; then
    read -p "No git user email set. Enter your email: " EMAIL 
    git config --global user.email "$EMAIL"
else
    echo "$EMAIL"
fi
echo

# Rest of script to display configs
echo "Global Git Configs:"
git config --global --list

# Other git config checks.....
```

The key changes:

1. Check if user.name and user.email are set
2. If not set, prompt user to input them
3. Save the values into the global git config

Let me know if you have any other questions!



This a comprehensive script to check and configure git settings on Linux:

The key points:

- Defines a function to standardize reading/setting configs
- Reads and sets missing git configs
- Additional examples like editor, crlf, credentials
- Prints summary of settings



```
#!/bin/bash
# Script to verify and configure git settings

# Function to read config value
# Prompts for user input if not set
function read-git-config() {
  KEY=$1
  PROMPT=$2 
  
  VALUE=$(git config --global --get "$KEY")  
  if [ -z "$VALUE" ]; then
    read -p "$PROMPT" VALUE
    git config --global "$KEY" "$VALUE"
  else
    echo $VALUE
  fi  
}

# Set user name
echo "Git User Name:"
read-git-config "user.name" "Enter git user name: "
echo

# Set user email 
echo "Git User Email:"
read-git-config "user.email" "Enter git user email: "  
echo

# Set default editor
echo "Git Default Editor:"
read-git-config "core.editor" "Enter default editor (vi, nano, etc): "
echo

# Set autocrlf setting  
echo "Git Auto CRLF:"
read-git-config "core.autocrlf" "Enter git auto crlf setting (true, false, input): "
echo

# Set credential cache timeout
echo "Git Credential Timeout:"
read-git-config "credential.helper" "Enter git credential timeout (seconds): "

echo
echo "Global Config Summary:" 
git config --global --list

echo  
echo "User Config File:"
cat ~/.gitconfig | grep -v "#"
```



Example input for all the git configuration settings that the script will prompt for, assuming none of them are set initially on a new machine:

```
Git User Name:
John Doe 

Git User Email:

john.doe@example.com

Git Default Editor:  

nano

Git Auto CRLF:

input

Git Credential Timeout:  

3600
```

When prompted:

- For user.name provide your full name, e.g. `John Doe`
- For user.email provide your email, e.g `john.doe@example.com`
- For core.editor provide your preferred text editor, e.g. `nano`, `vi`, `emacs`, etc
- For core.autocrlf use `true` to convert LF to CRLF on commit, `false` to disable, or `input` to convert CRLF to LF on commit
- For credential.helper provide timeout in seconds, e.g. `3600` for 1 hour

This will configure all the essential git settings for a new git user and machine. Let me know if you need any clarification or have additional questions!



If you are running on a Linux machine, the recommended setting for core.autocrlf would be `input`.

This configures git to convert CRLF line endings to LF when committing code:

```
Git Auto CRLF:  
input
```

The reasons to use `input` on Linux are:

1. Linux uses LF line endings, so this will normalize CRLF from Windows files to LF on commit
2. It will prevent needlessly converting LF to CRLF on every commit
3. If working with Windows machines, files will have consistent LF endings in the repo
4. Then Windows users can handle conversion on checkout

So in summary, for Linux:

- `input` - Convert CRLF to LF on commit



The steps to configure your Linux user to connect to GitLab via SSH, and load the SSH key automatically on terminal open:

1. Generate SSH key pair on Linux machine:

```
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

Press enter when asked for location and passphrase.

1. Add the public key to your GitLab account:

- Copy contents of ~/.ssh/id_rsa.pub
- In GitLab, go to Profile Settings > SSH Keys
- Paste the key

1. Enable ssh-agent to load keys on login:

```
echo 'eval $(ssh-agent -s)' >> ~/.bashrc
echo 'ssh-add ~/.ssh/id_rsa' >> ~/.bashrc
```

1. Reload .bashrc or open a new terminal

Now ssh-agent will automatically load your ssh key on every login.

Test with:

```
ssh -T git@gitlab.com
```

Say yes to fingerprint prompt.