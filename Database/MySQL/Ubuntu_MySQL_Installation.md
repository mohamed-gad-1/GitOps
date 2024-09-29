## Linux shell script to install the latest MySQL on Ubuntu. 

## This script will:

1. Update the package list.
2. Install MySQL.
3. Secure the MySQL installation by setting a root password and removing anonymous users.

```bash
#!/bin/bash

# Update the package list
echo "Updating package list..."
sudo apt-get update -y

# Install MySQL Server
echo "Installing MySQL Server..."
sudo apt-get install mysql-server -y

# Check MySQL service status
echo "Checking MySQL service status..."
sudo systemctl status mysql

# Secure the MySQL installation
echo "Securing MySQL installation..."
sudo mysql_secure_installation

# Prompt user to set the root password
echo "Please set the MySQL root password when prompted."

# Optionally, you can set the root password programmatically (not recommended for production)
# sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'yourpassword';"
# sudo mysql -e "FLUSH PRIVILEGES;"

# Display MySQL version
echo "MySQL installation complete. Here is the MySQL version:"
mysql --version

# Display MySQL service status
echo "MySQL service status:"
sudo systemctl status mysql

# Optionally, start and enable MySQL service
echo "Starting and enabling MySQL service..."
sudo systemctl start mysql
sudo systemctl enable mysql

# Final message
echo "MySQL installation and setup complete. You can now connect to MySQL using 'mysql -u root -p'."
```

### Explanation:

1. **Update the package list**: `sudo apt-get update -y` ensures that the package list is up-to-date.

2. **Install MySQL Server**: `sudo apt-get install mysql-server -y` installs the latest version of MySQL Server.

3. **Check MySQL service status**: `sudo systemctl status mysql` checks if the MySQL service is running.

4. **Secure the MySQL installation**: `sudo mysql_secure_installation` runs the MySQL secure installation script, which helps to set a root password, remove anonymous users, and disable remote root login.

5. **Prompt user to set the root password**: The script prompts the user to set the root password during the secure installation process.

6. **Display MySQL version**: `mysql --version` displays the installed MySQL version.

7. **Display MySQL service status**: `sudo systemctl status mysql` shows the current status of the MySQL service.

8. **Start and enable MySQL service**: `sudo systemctl start mysql` and `sudo systemctl enable mysql` ensure that the MySQL service is started and enabled to start on boot.

### Usage:

1. Save the script to a file, e.g., `install_mysql.sh`.
2. Make the script executable: `chmod +x install_mysql.sh`.
3. Run the script: `./install_mysql.sh`.

### Notes:

- The script uses `mysql_secure_installation` to secure the MySQL installation, which is interactive and requires user input.
- If you want to automate the root password setting, you can uncomment the optional lines in the script, but this is not recommended for production environments.

