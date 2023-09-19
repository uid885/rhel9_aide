#!/bin/bash -
# Author    : Christo Deale
# Date	    : 2023-09-19
# rhel9_aide: Utility to Install/Scan & Update Host Based IDS
#             Advanced Intrusion Detection Environment

# Verify if AIDE is installed
if ! command -v aide &> /dev/null; then
    echo "AIDE is not installed. Installing..."
    yum install aide -y
fi

# Add entries to /etc/aide.conf if they don't already exist
if ! grep -q "# Binaries check" /etc/aide.conf; then
    echo "# Binaries check" >> /etc/aide.conf
    echo "/bin        CONTENT_EX" >> /etc/aide.conf
    echo "/usr/bin    CONTENT_EX" >> /etc/aide.conf
    echo "/sbin       CONTENT_EX" >> /etc/aide.conf
    echo "/usr/sbin   CONTENT_EX" >> /etc/aide.conf
fi

# Initialize AIDE if the database doesn't exist
if [ ! -f /var/lib/aide/aide.db.gz ]; then
    aide --init
    mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
fi

# Function to run AIDE check and mail the log file
run_aide_check() {
    echo "Running AIDE check..."
    aide --check > /var/log/aide/aide.log
    datestamp=$(date +"%Y-%m-%d")
    mail -s "AIDE Report on $datestamp" name@email.com < /var/log/aide/aide.log    #YOUR Email Here
}

# Function to update AIDE database
update_aide_db() {
    echo "Updating AIDE database..."
    aide --update
}

# Main script logic
while true; do
    echo "Please select an option:"
    echo "1. Run AIDE check and mail log file"
    echo "2. Update AIDE database"
    echo "3. Exit"

    read -p "Enter option number: " option

    case $option in
        1)
            run_aide_check
            ;;
        2)
            update_aide_db
            ;;
        3)
            exit
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done
