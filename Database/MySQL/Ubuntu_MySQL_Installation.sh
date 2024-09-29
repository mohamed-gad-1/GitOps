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
# sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'str0ngPassw0rd';"
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