# Identify the container
docker ps

# Create mount directory
#mkdir /home/user/mount_dir

heck_sshfs() {
    if ! command -v sshfs &> /dev/null; then
        echo "sshfs is not installed. installng it using package manager."
        sudo apt-get install sshfs
        #exit 1
    else
            echo "sshfs is install in the system, continuing..."
    fi
}

# Function to mount the remote directory
mount_remote() {
    remote_user=sharda
    remote_host=10.10.11.111
    remote_dir=/home/sharda/prameet
    mount_point=/home/sharda/prameet

   # Create the local mount point if it doesn't exist
    if [ ! -d "$mount_point" ]; then
        echo "Creating local mount point: $mount_point"
        sudo mkdir -p "$mount_point"
    fi

    # Mount the remote directory using sshfs
    echo "Mounting $remote_user@$remote_host:$remote_dir to $mount_point"
    sshfs "$remote_user@$remote_host:$remote_dir" "$mount_point"

    if [ $? -eq 0 ]; then
        echo "Remote directory successfully mounted at $mount_point"
    else
        echo "Failed to mount the remote directory."
    fi
}


# Copy data from container to mount directory
docker cp prameet-image:/var/www/html /home/user/mount_dir

# Stop the container
docker stop prameet-image

# Verify the data
ls /home/user/mount_dir

#copy the script in /etc/rc0.d/ to run on system shutdown
#sudo ln -s /path/to/copy_and_stop.sh /etc/rc0.d/K01copy_and_stop
