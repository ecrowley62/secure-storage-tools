### Overview
Simple script for opening and mounting an encrypted partition. Might also
have this backup the contents to another encrypted partition, or something like that. Will see how this evolves.

### Base commands
- This script is a wrapper around cryptsetup and mount. Specifically:
  - `cryptesetup open _device_ _name_`
  - `mount -t _fstype_ /dev/mapper/_name_ _mnt_dir_`
  - `umount _mnt_dir_`
  - `cryptsetup close _name_`
