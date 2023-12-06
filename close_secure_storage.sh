#!/usr/bin/bash
################################################################
# Shell script for closing/unmount an open encrypted partition #
#                                                              #
# Auth: Eric Crowley                                           #
# Start Date: 2023-06-03                                       #
################################################################

# help function for describing how to use this utility
help() {
    echo "Close and unmount an open encrypted partition"
    echo
    echo "-n The name of the mapped cryptsetup object. If"
    echo "   this is not provided, then active mappings will"
    echo "   be identified and the first one found will be "
    echo "   used as the target for this operation"
    echo "-h Print this help message"
    echo
}

# Parse input arguments
while getopts "n:h" inputvalue; do
    case "${inputvalue}" in
        n)
            CRYPT_NAME=${OPTARG}
            ;;
        h)
            help
            exit 0
            ;;
        *)
            echo "Unrecognized arg provided. Do you need help?"
            echo
            help
            exit 1
            ;;
    esac
done

# Inform the user that default environment based values will be used
# when no args are provided to this
if [ $# -eq 0 ]; then
    echo "No params were provided. Using environment based defaults"
    echo
fi

# If no mapper name was provided for the open partition, use the first
# open mapper listed by lsblk. If no mapper can be identified, print an
# error message and exit. If a mapper was provided, verify it exists
if [ -z $CRYPT_NAME ]; then
    echo "No -n arg provided. Using first open crypt mapper listed by lsblk"
    CRYPT_NAME=$(lsblk | grep crypt | cut -d' ' -f3 | cut -c 7- )
    if [ -z $CRYPT_NAME ]; then
        echo "No mapper was identified"
        exit 1
    else
        echo "Mapper object identified is $CRYPT_NAME"
        echo
    fi
else
    echo "Verifying user provided encrypted mapper: $CRYPT_NAME"
    CRYPT_CHECK=$(lsblk | grep crypt | grep $CRYPT_NAME)
    if [ -z $CRYPT_CHECK ]; then
        echo "User provided mapper was not found. Exiting"
        exit 1
    fi
fi

# Identify the file system that the open mapper is mounted to
echo "Identifying the director the mapper is mounted at"
MOUNT_DIRECTORY=$(lsblk | grep crypt | grep $CRYPT_NAME | cut -d' ' -f13)
if [ -z $MOUNT_DIRECTORY ]; then
    echo "No mountpoint is associated with mapper $CRYPT_NAME"
    echo "Unmounting operations will be skipped"
    echo
    PERFORM_UNMOUNT=0
else
    echo "Mapper $CRYPT_NAME is mounted at $MOUNT_DIRECTORY"
    echo
    PERFORM_UNMOUNT=1
fi

# Unmount the mapper if it is mounted
if [ $PERFORM_UNMOUNT -eq 1 ]; then
    echo "Unmounting mapper from mount point $MOUNT_DIRECTORY"
    sudo umount $MOUNT_DIRECTORY
    if [ $? -eq 0 ]; then
        echo "Successfully unmounted the mapper"
        echo
    else
        echo "Failed to unmount the mapper"
        exit 1
    fi
fi

# Close the open mapper object
echo "Closing mapper $CRYPT_NAME"
sudo cryptsetup close $CRYPT_NAME
if [ $? -eq 0 ]; then
    echo "Successfully closed mapper interface"
    echo
    exit 0
else
    echo "Failed to close mapper interface"
    echo
    exit 1
fi

