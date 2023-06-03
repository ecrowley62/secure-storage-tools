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
    echo "   If this is not provided, then the SECURE_STORAGE_DEVICE_PATH"
    echo "   env variable will be used for this value"
    echo "-s The directory to mount the partition on. If this is not "
    echo "   provided, then the SECURE_STORAGE_DIRECTORY environment"
    echo "   variable will be used, if it exists"
    echo "-n The name cryptsetup should give to the mapping for the decrypted"
    echo "   drive. If not provided, a random set of characters will be used"
    echo "   for the mapping name"
    echo "-h Print this help message"
    echo
}

# Generate a random id string and set it to the RANDOM_ID variable
set_random_uuid () {
    RAW_RANDOM_ID=$(echo $RANDOM | md5sum | sed "s/ -//g")
    RANDOM_ID="${RAW_RANDOM_ID:0:10}"
}

# Get input argument values
while getopts "d:s:n:h" inputvalue; do
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
        h)
            help
            exit 0
            ;;
        *)
            echo "Unrecognized arg provided"
            echo
            help
            exit 1
            ;;
    esac
done

# Display information about defautl values being pulled from the env
# if no arguments are provided to this script
if [ $# -eq 0 ]; then
    echo "No params were provided. Using environment based defaults"
    echo
fi

# Set the device path using an env var if not device path was provided.
# If no value was provided, and no env var exists, throw an error
if [ -z $ENCRYPTED_DEVICE ]; then
    if [ -z $SECURE_STORAGE_DEVICE_PATH ]; then
        echo "Env var SECURE_STORAGE_DEVICE_PATH is not set"
        echo "Set this env var or provide a device using the -d param"
        exit 1
    else
        ENCRYPTED_DEVICE=$SECURE_STORAGE_DEVICE_PATH
        echo "Using $ENCRYPTED_DEVICE as encrypted storage source"
        echo
    fi
fi

# Verify the device path points to an actual device
if [ ! -b $ENCRYPTED_DEVICE ]; then
    echo "Encrypted device $ENCRYPTED_DEVICE is NOT valid"
    exit 1
else
    echo "Encrypted device $ENCRYPTED_DEV is valid"
fi

# Set the mount directory using an env var, if a arg
# was not provided for this value. If no env var exists 
# and a value was not provided, exit
if [ -z $MOUNT_DIRECTORY ]; then
    if [ -z $SECURE_STORAGE_DIRECTORY ]; then
        echo "Env var SECURE_STORAGE_DIRECTORY is not set"
        echo "Set this env var or provide a directory using the -s param"
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
    echo "Mount directory $MOUNT_DIRECTORY is not valid"
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
