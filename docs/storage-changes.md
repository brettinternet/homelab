# Storage changes

After adding or removing disks to the storage pool, run:

```
sudo mount -o remount /mnt/storage
sudo exportfs -arv
```
