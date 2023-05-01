#/usr/bin/bash
############################################################
# Shell script for opening/mounting an encrypted partition #
#                                                          #
# Auth: Eric Crowley                                       #
# Start Date: 2023-04-29                                   #
############################################################

# help function for describing how to use this utility
help() {
    echo "Open and mounts an encrypted partition"
    echo 
    echo "-d The full path to the partition (device) that is encrypted"
    echo "-s The directory to mount the partition on. If this is not "
    echo "   provided, then the SECURE_STORAGE_DIRECTORY environment"
    echo "   variable will be used, if it exists"
}

# Generate a random id string and set it to the RANDOM_ID variable
set_random_uuid () {
    RAW_RANDOM_ID=$(echo $RANDOM | md5sum | sed "s/ -//g")
    RANDOM_ID="${RAW_RANDOM_ID:0:10}"
}

# Get input argument values
while getopts "d:s:n:" inputvalue; do
    case "${inputvalue}" in
        d)
            ENCRYPTED_DEVICE=${OPTARG}
            ;;
        s)
            MOUNT_DIRECTORY=${OPTARG}
            ;;
        n)
            CRYPT_NAME=${OPTARG}
            ;;
        *)
            echo "Unrecognized arg provided"
            echo
            help
            exit 1
            ;;
    esac
done

# Check input argument values. Verify the provided device is a valid
# device. If so, print an info message indicating that
if [ $# -eq 0 ]; then
    echo "No params were provided. Do you need help?"
    echo
    help
    exit 1
elif [ -z $ENCRYPTED_DEVICE ]; then
    echo "No device provided"
    exit 1
elif [ ! -b $ENCRYPTED_DEVICE ]; then
    echo "Provided device $ENCRYPTED_DEVICE is NOT valid"
    exit 1
else
    echo "Provided device $ENCRYPTED_DEVICE is valid"
    echo
fi

# Set the mount directory using an env var, if a arg
# was not provided for this value. If no env var exists, exit
if [ -z $MOUNT_DIRECTORY ]; then
    if [ -z $SECURE_STORAGE_DIRECTORY ]; then
        echo "No mount directory provided and SECURE_STORAGE_DIRECTORY is not set"
        exit 1
    else
        MOUNT_DIRECTORY=$SECURE_STORAGE_DIRECTORY
        echo "Using $MOUNT_DIRECTORY as mount point"
        echo
    fi
else
    echo "Using $MOUNT_DIRECTORY as mount point"
    echo
fi

# Verify the mount directory is a valid directory
if [ ! -d $MOUNT_DIRECTORY ]; then
    echo "Provided mount directory $MOUNT_DIRECTORY is not valid"
    exit 1
fi

# Create an id string that will be the crypt device mapper name if a crypt name
# was not provided
if [ -z $CRYPT_NAME ]; then
    echo "No value found for crypt name. Generating uuid name"
    set_random_uuid
    CRYPT_NAME=$RANDOM_ID
    echo "Using $CRYPT_NAME for crypt mapper name"
    echo
else
    echo "Using $CRYPT_NAME for crypt mapper name"
    echo
fi

# Decrypt the device
sudo cryptsetup open $ENCRYPTED_DEVICE $CRYPT_NAME
if [ $? -eq 0 ]; then
    echo "Successfully decrypted $ENCRYPTED_DEVICE"
    echo
else
    echo "Failed to decrypt $ENCRYPTED_DEVICE"
    exit 1
fi

# Mount the file system
sudo mount -t ext4 "/dev/mapper/$CRYPT_NAME" "$MOUNT_DIRECTORY"
if [ $? -eq 0 ]; then
    echo "Successfully mounted device $CRYPT_NAME to $MOUNT_DIRECTORY"
    exit 0
else
    echo "FAILED to mount $CRYPT_NAME to $MOUNT_DIRECTORY"
    exit 1
fi
