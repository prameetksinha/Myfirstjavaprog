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
snapshot="_snapshot"

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
    #ssh-copy-id $remote_user@$remote_host

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

    echo "commiting container to save in $container_name$snapshot':latest"
    docker commit $container_id $container_name$snapshot:latest

    echo "saving container image $container_name"
    #docker save -o $container_name:latest | gzip > $current_host"_"$container_id.tar.gz

    docker save -o $current_host"_"$container_id$snapshot.tar.gz $container_name$snapshot:latest

    docker images

    echo "dir list is $(ls -l)"

    echo "copying container $current_host'_'$container_id'_snapshot.tar.gz' to $remote_dir"
    scp $(echo $current_host'_'$container_id'_snapshot.tar.gz') $remote_dir
 
    echo "Stopping container $container_id"
    docker stop $container_id

    echo "Verifing the data copied to remote location"
    ls $remote_dir

}

save_container() {

# Check if container name/ID is provided
if [ -z "$container_id" ]; then
    echo "Error: Please provide a container name or ID."
    echo "Usage: $0 <container_name_or_id> [output_tar_name]"
    umount
    exit 1
fi

CONTAINER=$container_id
OUTPUT_TAR=${2:-"${CONTAINER}_${current_host}_snapshot.tar"}  # Default tar name if not provided

# Check if the container exists and is running
if ! docker ps -a --format '{{.Names}} {{.ID}}' | grep -q "$CONTAINER"; then
    echo "Error: Container '$CONTAINER' not found."
    umount
    exit 1
fi

# Get the container ID if a name is provided
CONTAINER_ID=$(docker ps -a --filter "name=$CONTAINER" --format "{{.ID}}" | head -n 1)
if [ -z "$CONTAINER_ID" ]; then
    CONTAINER_ID=$CONTAINER  # Assume it's already an ID
fi

echo "Saving container: $CONTAINER (ID: $CONTAINER_ID)"

# Step 1: Commit the container to an image
IMAGE_NAME="${CONTAINER}_image"
echo "Committing container to image: $IMAGE_NAME..."
docker commit "$CONTAINER_ID" "$IMAGE_NAME"

# Step 2: Export the container filesystem to a tar file
echo "Exporting container to $OUTPUT_TAR..."
docker export -o "$OUTPUT_TAR" "$CONTAINER_ID"

# Step 3: Display file size and verification
if [ -f "$OUTPUT_TAR" ]; then
    echo "Container saved successfully as $OUTPUT_TAR"
    ls -lh "$OUTPUT_TAR"
else
    echo "Error: Failed to create $OUTPUT_TAR"
    umount
    exit 1
fi

echo "copying container $OUTPUT_TAR to $remote_dir"
scp $OUTPUT_TAR $remote_dir

ls -l $remote_dir

# Step 4: Provide instructions for resuming on another machine
#echo -e "\nTo resume the container on another machine:"
#echo "1. Copy '$OUTPUT_TAR' to the target machine."
#echo "2. Import and run it with the following commands:"
#echo "   docker import $OUTPUT_TAR ${IMAGE_NAME}"
#echo "   docker run -d --name resumed_$CONTAINER $IMAGE_NAME"
#echo "Note: Adjust 'docker run' options (e.g., ports, volumes) as needed."

}

mount_remote

echo "list mount or current host dir"
ls -l $mount_dir

echo "list remote dir"
ls -l $remote_dir

#copy_container
save_container

unmount_remote

#copy the script in /etc/rc0.d/ to run on system shutdown
#sudo ln -s /home/sharda/prameet/random_code/copy_and_stop.sh /etc/rc0.d/K01copy_and_stop
#https://github.com/ricardobranco777/docker-volumes.sh
