# Git Setup Script

This setup script automates the process of configuring a Git user, with useful settings like user credentials, default editor, CRLF handling, and SSH key authentication. Running the script will interactively prompt the user for values to put into the global Git configuration, enabling a full Git environment tailored for developers working on Linux machines connecting to remote repositories.

## Features

- Configures Git username and email.
- Sets default text editor for commit messages.
- Controls handling of CRLF/LF line endings.
- Enables SSH key authentication to services like GitHub/GitLab.
- Automatically starts `ssh-agent` to load keys on login.

## More Information

- **CRLF** refers to the Carriage Return Line Feed characters, handled differently by Linux vs Windows.
- **ssh-agent** manages SSH keys for passwordless authentication to remote Git repositories.
- **gitconfig** controls per-user settings like author info, editor, line endings.

## Script Details

The script performs the following steps:

1. **Verify and Configure Git Settings**:
   - Checks if `user.name` and `user.email` are set.
   - Prompts the user to input them if they are not set.
   - Sets default editor, CRLF handling, and credential cache timeout.

2. **SSH Key Configuration**:
   - Generates an SSH key pair if not already present.
   - Adds the public key to the user's GitLab or GitHub account.
   - Configures `ssh-agent` to load the SSH key on login.

3. **Display Configuration Summary**:
   - Lists all global Git configurations.
   - Displays the user's `.gitconfig` file.

## Usage

The `setup_git.sh` script modifies the per-user `~/.gitconfig` file. Run the script from your home directory:

```bash
./setup_git.sh
```

Follow the prompts to input your Git configurations. Default reasonable values are provided if needed.

## Example Input

Assuming none of the Git configurations are set initially on a new machine:

- **Git User Name**: John Doe
- **Git User Email**: john.doe@example.com
- **Git Default Editor**: nano
- **Git Auto CRLF**: input
- **Git Credential Timeout**: 3600

## SSH Key Configuration

To configure your Linux user to connect to GitLab via SSH and load the SSH key automatically on terminal open:

1. **Generate SSH Key Pair**:

   ```bash
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   ```

   Press enter when asked for location and passphrase.

2. **Add Public Key to GitLab Account**:

   - Copy contents of `~/.ssh/id_rsa.pub`.
   - In GitLab, go to Profile Settings > SSH Keys.
   - Paste the key.

3. **Enable `ssh-agent` to Load Keys on Login**:

   ```bash
   echo 'eval $(ssh-agent -s)' >> ~/.bashrc
   echo 'ssh-add ~/.ssh/id_rsa' >> ~/.bashrc
   ```

   Reload `.bashrc` or open a new terminal.

4. **Test SSH Connection**:

   ```bash
   ssh -T git@gitlab.com
   ```

   Say yes to the fingerprint prompt.

### Script: `setup_git.sh`


```bash
#!/bin/bash

# Function to read and set Git config value
function set_git_config() {
  KEY=$1
  PROMPT=$2
  
  VALUE=$(git config --global --get "$KEY")
  if [ -z "$VALUE" ]; then
    read -p "$PROMPT" VALUE
    git config --global "$KEY" "$VALUE"
  else
    echo "$VALUE"
  fi
}

# Function to generate and configure SSH key
function configure_ssh_key() {
  if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
    echo 'eval $(ssh-agent -s)' >> ~/.bashrc
    echo 'ssh-add ~/.ssh/id_rsa' >> ~/.bashrc
    echo "SSH key generated and configured for automatic loading."
  else
    echo "SSH key already exists."
  fi
}

# Set user name
echo "Git User Name:"
set_git_config "user.name" "Enter git user name: "
echo

# Set user email
echo "Git User Email:"
set_git_config "user.email" "Enter git user email: "
echo

# Set default editor
echo "Git Default Editor:"
set_git_config "core.editor" "Enter default editor (vi, nano, etc): "
echo

# Set autocrlf setting
echo "Git Auto CRLF:"
set_git_config "core.autocrlf" "Enter git auto crlf setting (true, false, input): "
echo

# Set credential cache timeout
echo "Git Credential Timeout:"
set_git_config "credential.helper" "Enter git credential timeout (seconds): "
echo

# Configure SSH key
configure_ssh_key

# Display global config summary
echo "Global Config Summary:"
git config --global --list
echo

# Display user config file
echo "User Config File:"
cat ~/.gitconfig | grep -v "#"
```

### Explanation:

1. **Function Definitions**:
   - `set_git_config`: Reads and sets Git configuration values.
   - `configure_ssh_key`: Generates and configures SSH keys for automatic loading.

2. **Git Configuration**:
   - Prompts the user for `user.name`, `user.email`, `core.editor`, `core.autocrlf`, and `credential.helper`.
   - Sets these values in the global Git configuration.

3. **SSH Key Configuration**:
   - Generates an SSH key pair if not already present.
   - Configures `ssh-agent` to load the SSH key on login.

4. **Display Configuration Summary**:
   - Lists all global Git configurations.
   - Displays the user's `.gitconfig` file.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.