# Identify the container
docker ps

# Create mount directory
#mkdir /home/user/mount_dir

remote_user=sharda
remote_host=10.10.11.111
remote_dir=/home/sharda/prameet
mount_point=/home/sharda/prameet
current_host=10.10.11.77
#container_name="prameet-image"
container_id=$(docker container ls  | grep 'prameet-image' | awk '{print $1}')
container_name=$(docker container ls  | grep 'prameet-image' | awk '{print $2}')

check_sshfs() {
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

   # Create the local mount point if it doesn't exist
    if [ ! -d "$mount_point" ]; then
        echo "Creating local mount point: $mount_point"
        sudo mkdir -p "$mount_point"
	    sudo chmod 777 $mount_point
    fi

    #ssh-keygen -t rsa -b 4096
    ssh-copy-id $remote_user@$remote_host

    # Mount the remote directory using sshfs
    echo "Mounting $remote_user@$remote_host:$remote_dir to $mount_point"
    sshfs "$remote_user@$remote_host:$remote_dir" "$mount_point"

    if [ $? -eq 0 ]; then
        echo "Remote directory successfully mounted at $mount_point"
    else
        echo "Failed to mount the remote directory."
    fi
}

unmount_remote() {
   #read -p "Enter local mount point to unmount (e.g., /mnt/remote_space): " mount_point

    if mountpoint -q "$mount_point"; then
        echo "Unmounting $mount_point"
        sudo fusermount -u "$mount_point"
        #sudo umount -l "$mount_point"
        if [ $? -eq 0 ]; then
            echo "Successfully unmounted $mount_point"
        else
            echo "Failed to unmount $mount_point"
        fi
    else
        echo "$mount_point is not a valid mount point."
    fi
}


#copy container in mounted dir
copy_container() {
    echo "save and copying the container from $current_host to $remote_host"

    # 
    # ToDo : Send a mail with all the information
    #

    echo "saving container image $container_name"
    docker save $container_name:latest | gzip > $current_host"_"$container_id.tar.gz

    echo "dir list is $(ls -l)"

    echo "copying container $current_host"_"$containerid.tar.gz to $remote_dir"
    docker cp $current_host"_"$container_id.tar.gz $remote_dir
 
    echo "Stopping container $container_id"
    docker stop $container_id

    echo "Verifing the data copied to remote location"
    ls $remote_dir

}

mount_remote

echo "list mount or current host dir"
ls -l $mount_dir

echo "list remote dir"
ls -l $remote_dir

copy_container

unmount_remote

#copy the script in /etc/rc0.d/ to run on system shutdown
#sudo ln -s /home/sharda/prameet/random_code/copy_and_stop.sh /etc/rc0.d/K01copy_and_stop
#https://github.com/ricardobranco777/docker-volumes.sh
