#!/bin/bash

MYSQL_ROOT_PASSWORD=""

# Function to create data folders
function create_data_folders() {
  sudo rm -rf /opt/data/mysql/web-fam-sofi
  sudo mkdir -p /opt/data/mysql/web-fam-sofi
  sudo mkdir -p /opt/data/mysql/web-fam-sofi-info
  sudo chown -R $USER:$USER /opt/data/mysql/web-fam-sofi  # Set ownership to MySQL user (UID 999)
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
  sudo docker run -d --name mysql-container -v /opt/data/mysql/web-fam-sofi:/var/lib/mysql mysql/mysql:latest
}

# Function to fetch and MySQL root password
function get_mysql_root_password() {
  # Fetch the generated root password from container logs
  MYSQL_ROOT_PASSWORD=$(docker logs mysql-container 2>&1 | grep "GENERATED ROOT PASSWORD" | awk '{print $NF}')
  echo ""
  echo $MYSQL_ROOT_PASSWORD
  echo ""
  
  # Wait for MySQL container to be ready
  
  while ! docker exec mysql-container mysqladmin -uroot -p"$MYSQL_ROOT_PASSWORD" ping --silent &> /dev/null ; do
    echo "Waiting for MySQL container to be ready..."
    sleep 5
  done
}

# Function to create MySQL super admin user
function create_mysql_user() {
  local MYSQL_USER="admin"
  local MYSQL_PASSWORD=$(openssl rand -base64 32)
  
  sudo docker exec -i mysql-container mysql --connect-expired-password -uroot -p"$MYSQL_ROOT_PASSWORD" <<EOF
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
  get_mysql_root_password
  create_mysql_user
  #create_new_db
  #create_connection_string
  
  echo "MySQL container setup complete."
}

# Run the main function
main