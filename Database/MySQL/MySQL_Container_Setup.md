# MySQL Container Setup for Web Application

This script automates the setup of a MySQL container on an Ubuntu system, ensuring data persistence and secure configuration. The script performs the following tasks:

1. **Create Data Folders**:
   - Creates data folders for MySQL under `/opt/data/mysql/web-fam-sofi` and `/opt/data/mysql/web-fam-sofi-info`.

2. **Download and Run MySQL Container**:
   - Downloads the latest MySQL container image.
   - Runs the MySQL container, mounting the data folders to persist database files.

3. **Create MySQL Super Admin User**:
   - Creates a new MySQL user with super admin privileges.
   - Generates a strong password following MySQL recommendations.

4. **Store Credentials Securely**:
   - Encodes the MySQL user and password as base64 and stores them in a file under `/opt/data/mysql/web-fam-sofi-info`.

5. **Create New Database**:
   - Creates a new database named `sofitel-fam-db`.

6. **Store Connection String**:
   - Creates a file with the connection string to connect to the new MySQL server and database.

## Prerequisites

- Ubuntu operating system.
- Docker installed and configured.
- Sudo privileges.

## Usage

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yourusername/yourrepository.git
   cd yourrepository
   ```

2. **Make the Script Executable**

   ```bash
   chmod +x setup_mysql_container.sh
   ```

3. **Run the Script**

   ```bash
   ./setup_mysql_container.sh
   ```

The error message indicates that the MySQL container is failing to start due to a permission issue with the `binlog.index` file. This is likely because the mounted volume `/opt/data/mysql/web-fam-sofi` does not have the correct permissions for the MySQL user inside the container.

To resolve this, we need to ensure that the mounted volume has the appropriate permissions. We can do this by setting the correct permissions on the host directory before starting the container.

### Script: `setup_mysql_container.sh`

```bash
#!/bin/bash

# Function to create data folders
function create_data_folders() {
  sudo mkdir -p /opt/data/mysql/web-fam-sofi
  sudo mkdir -p /opt/data/mysql/web-fam-sofi-info
  sudo chown -R 999:999 /opt/data/mysql/web-fam-sofi  # Set ownership to MySQL user (UID 999)
  sudo chown -R $USER:$USER /opt/data/mysql/web-fam-sofi-info
}

# Function to check if container exists and handle user choice
function handle_existing_container() {
  if docker ps -a --format '{{.Names}}' | grep -q "^mysql-container$"; then
    echo "Container 'mysql-container' already exists."
    echo "1. Delete the old container and create a new one."
    echo "2. Rename the old container and create a new one."
    echo "3. Cancel."
    read -p "Choose an option (1/2/3): " choice

    case $choice in
      1)
        echo "Deleting the old container..."
        docker rm -f mysql-container
        ;;
      2)
        read -p "Enter a new name for the old container: " new_name
        echo "Renaming the old container to '$new_name'..."
        docker rename mysql-container $new_name
        ;;
      3)
        echo "Operation canceled."
        exit 0
        ;;
      *)
        echo "Invalid option. Exiting."
        exit 1
        ;;
    esac
  fi
}

# Function to download and run MySQL container
function run_mysql_container() {
  docker run -d --name mysql-container -v /opt/data/mysql/web-fam-sofi:/var/lib/mysql mysql/mysql-server:latest
}

# Function to fetch and set MySQL root password
function set_mysql_root_password() {
  # Fetch the generated root password from container logs
  MYSQL_ROOT_PASSWORD=$(docker logs mysql-container 2>&1 | grep "GENERATED ROOT PASSWORD" | awk '{print $NF}')
  
  # Wait for MySQL container to be ready
  while ! docker exec mysql-container mysqladmin -uroot -p"$MYSQL_ROOT_PASSWORD" ping --silent &> /dev/null ; do
    echo "Waiting for MySQL container to be ready..."
    sleep 5
  done

  # Reset the root password to a known value
  docker exec -i mysql-container mysql -uroot -p"$MYSQL_ROOT_PASSWORD" <<EOF
  ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_root_password';
EOF
}

# Function to create MySQL super admin user
function create_mysql_user() {
  local MYSQL_USER="admin"
  local MYSQL_PASSWORD=$(openssl rand -base64 32)
  
  docker exec -i mysql-container mysql -uroot -p'new_root_password' <<EOF
  CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
  GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%' WITH GRANT OPTION;
  FLUSH PRIVILEGES;
EOF

  echo "$MYSQL_USER:$MYSQL_PASSWORD" | base64 | sudo tee /opt/data/mysql/web-fam-sofi-info/mysql_credentials.txt > /dev/null
}

# Function to create new database
function create_new_db() {
  local DB_NAME="sofitel-fam-db"
  
  docker exec -i mysql-container mysql -uroot -p'new_root_password' <<EOF
  CREATE DATABASE $DB_NAME;
EOF
}

# Function to create connection string file
function create_connection_string() {
  local MYSQL_USER="admin"
  local MYSQL_PASSWORD=$(openssl rand -base64 32)
  local DB_NAME="sofitel-fam-db"
  local CONNECTION_STRING="mysql://$MYSQL_USER:$MYSQL_PASSWORD@localhost:3306/$DB_NAME"
  
  echo "$CONNECTION_STRING" | sudo tee /opt/data/mysql/web-fam-sofi-info/mysql_connection_string.txt > /dev/null
}

# Main script execution
function main() {
  create_data_folders
  handle_existing_container
  run_mysql_container
  set_mysql_root_password
  create_mysql_user
  create_new_db
  create_connection_string
  
  echo "MySQL container setup complete."
}

# Run the main function
main
```

### Explanation:

1. **Create Data Folders**:
   - Uses `sudo mkdir -p` to create nested directories for MySQL data persistence.
   - Sets ownership of `/opt/data/mysql/web-fam-sofi` to the MySQL user inside the container (UID 999).
   - Sets ownership of `/opt/data/mysql/web-fam-sofi-info` to the current user.

2. **Check for Existing Container**:
   - Checks if the container `mysql-container` already exists.
   - Prompts the user to choose between deleting the old container, renaming it, or canceling the operation.

3. **Download and Run MySQL Container**:
   - Runs the MySQL container in daemon mode with the specified data volumes.

4. **Fetch and Set MySQL Root Password**:
   - Fetches the generated root password from the container logs.
   - Waits for the MySQL container to be ready before attempting to reset the root password.
   - Resets the root password to a known value (`new_root_password`).

5. **Create MySQL Super Admin User**:
   - Generates a strong password using `openssl`.
   - Creates a new MySQL user with super admin privileges.
   - Uses `sudo tee` to write the encoded credentials to the file with appropriate permissions.

6. **Create New Database**:
   - Creates a new database named `sofitel-fam-db`.

7. **Store Connection String**:
   - Creates a file with the connection string to connect to the new MySQL server and database.
   - Uses `sudo tee` to write the connection string to the file with appropriate permissions.

This script ensures a secure and efficient setup of a MySQL container for a web application, with data persistence and proper credential management, while also handling existing containers gracefully and ensuring the correct permissions for the mounted volume.
## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
