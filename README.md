## Домашнее задание к занятию "3.5. Файловые системы" 
1. **Узнайте о [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB) (разряженных) файлах.**  
**Ответ:** Узнал. Интересная технология для более эффективного использования файловой системы, со своими плюсами и минусами. Век живи - век учись.  
2. **Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?**  
**Ответ:** Не могут, так как оба файла являются хардлинками для одного и того же цифрового объекта (как это было хорошо объяснено в лекции).  
```
jenkidu@netology:~/3-5_FS$ vim matrix
jenkidu@netology:~/3-5_FS$ ll
total 8
drwxrwxr-x 2 jenkidu jenkidu 4096 сен 14 11:21 ./
drwxr-x--- 7 jenkidu jenkidu 4096 сен 14 11:21 ../
-rw-rw-r-- 1 jenkidu jenkidu    0 сен 14 11:21 matrix
jenkidu@netology:~/3-5_FS$ stat matrix 
  File: matrix
  Size: 0         	Blocks: 0          IO Block: 4096   regular empty file
Device: fd00h/64768d	Inode: 405331      Links: 1
Access: (0664/-rw-rw-r--)  Uid: ( 1000/ jenkidu)   Gid: ( 1000/ jenkidu)
Access: 2022-09-14 11:21:09.855377407 +0000
Modify: 2022-09-14 11:21:09.855377407 +0000
Change: 2022-09-14 11:21:09.855377407 +0000
 Birth: 2022-09-14 11:21:09.855377407 +0000
jenkidu@netology:~/3-5_FS$ ln matrix matrix.hlink
jenkidu@netology:~/3-5_FS$ ls -ila matrix*
405331 -rw-rw-r-- 2 jenkidu jenkidu 0 сен 14 11:21 matrix
405331 -rw-rw-r-- 2 jenkidu jenkidu 0 сен 14 11:21 matrix.hlink
jenkidu@netology:~/3-5_FS$ stat matrix
  File: matrix
  Size: 0         	Blocks: 0          IO Block: 4096   regular empty file
Device: fd00h/64768d	Inode: 405331      Links: 2
Access: (0664/-rw-rw-r--)  Uid: ( 1000/ jenkidu)   Gid: ( 1000/ jenkidu)
Access: 2022-09-14 11:21:09.855377407 +0000
Modify: 2022-09-14 11:21:09.855377407 +0000
Change: 2022-09-14 11:32:04.873747248 +0000
 Birth: 2022-09-14 11:21:09.855377407 +0000
jenkidu@netology:~/3-5_FS$ stat matrix.hlink 
  File: matrix.hlink
  Size: 0         	Blocks: 0          IO Block: 4096   regular empty file
Device: fd00h/64768d	Inode: 405331      Links: 2
Access: (0664/-rw-rw-r--)  Uid: ( 1000/ jenkidu)   Gid: ( 1000/ jenkidu)
Access: 2022-09-14 11:21:09.855377407 +0000
Modify: 2022-09-14 11:21:09.855377407 +0000
Change: 2022-09-14 11:32:04.873747248 +0000
 Birth: 2022-09-14 11:21:09.855377407 +0000 
 ```
3. **Сделайте vagrant destroy на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:** 

```Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.provider :virtualbox do |vb|
    lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
    lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
    vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
    vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
    vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
    vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
  end
end
```  

4. **Используя fdisk, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.**  
```
root@vagrant:~# lsblk | grep -v loop*
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                         8:0    0   64G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0  1.5G  0 part /boot
└─sda3                      8:3    0 62.5G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.3G  0 lvm  /
sdb                         8:16   0  2.5G  0 disk
sdc                         8:32   0  2.5G  0 disk
```

```
fdisk /dev/sdb
```

```
Command (m for help): n
```

```
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
```

```
Select (default p): p
```

```
Partition number (1-4, default 1):
First sector (2048-5242879, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-5242879, default 5242879): +2G
```

```
Created a new partition 1 of type 'Linux' and of size 2 GiB.
```

```
Command (m for help): p
```

```
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x02631626

Device     Boot Start     End Sectors Size Id Type
/dev/sdb1        2048 4196351 4194304   2G 83 Linux
```

```
Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): e
Partition number (2-4, default 2):
First sector (4196352-5242879, default 4196352):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242879, default 5242879):

Created a new partition 2 of type 'Extended' and of size 511 MiB.
```

```
Command (m for help): p
```

```
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x02631626

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdb1          2048 4196351 4194304    2G 83 Linux
/dev/sdb2       4196352 5242879 1046528  511M  5 Extended
```
Command (m for help): w - записать изменения на диск:
```
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

5. **Используя sfdisk, перенесите данную таблицу разделов на второй диск.**
```
# sfdisk -d /dev/sdb | sfdisk /dev/sdc
```

```
New situation:
Disklabel type: dos
Disk identifier: 0xb83f216d

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdc1          2048 4196351 4194304    2G 83 Linux
/dev/sdc2       4196352 5242879 1046528  511M 83 Linux
```

```
root@vagrant:~# lsblk | grep -v loop*
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                         8:0    0   64G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0  1.5G  0 part /boot
└─sda3                      8:3    0 62.5G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.3G  0 lvm  /
sdb                         8:16   0  2.5G  0 disk
├─sdb1                      8:17   0    2G  0 part
└─sdb2                      8:18   0  511M  0 part
sdc                         8:32   0  2.5G  0 disk
├─sdc1                      8:33   0    2G  0 part
└─sdc2                      8:34   0  511M  0 part
```
6. **Соберите mdadm RAID1 на паре разделов 2 Гб.**
```
# mdadm --create --verbose /dev/md0 -l 1 -n 2 /dev/sd{b1,c1}
```
7. **Соберите mdadm RAID0 на второй паре маленьких разделов.**
```
# mdadm --create --verbose /dev/md1 -l 0 -n 2 /dev/sd{b2,c2}
```

```
root@vagrant:~# lsblk | grep -v loop* 
NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT 
sda                         8:0    0   64G  0 disk 
├─sda1                      8:1    0    1M  0 part 
├─sda2                      8:2    0  1.5G  0 part  /boot 
└─sda3                      8:3    0 62.5G  0 part 
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.3G  0 lvm   / 
sdb                         8:16   0  2.5G  0 disk 
├─sdb1                      8:17   0    2G  0 part 
│ └─md0                     9:0    0    2G  0 raid1 
└─sdb2                      8:18   0  511M  0 part 
  └─md1                     9:1    0 1018M  0 raid0 
sdc                         8:32   0  2.5G  0 disk 
├─sdc1                      8:33   0    2G  0 part 
│ └─md0                     9:0    0    2G  0 raid1 
└─sdc2                      8:34   0  511M  0 part 
  └─md1                     9:1    0 1018M  0 raid0
```

8. **Создайте 2 независимых PV на получившихся md-устройствах.**
```
# pvcreate /dev/md0
```

```
# pvcreate /dev/md1
```

```
root@vagrant:~# pvdisplay
  --- Physical volume ---
  PV Name               /dev/sda3
  VG Name               ubuntu-vg
  PV Size               <62.50 GiB / not usable 0
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              15999
  Free PE               8000
  Allocated PE          7999
  PV UUID               x7S6t2-at3n-E9kU-cz28-gAH3-QU9H-vyVuNf

  "/dev/md0" is a new physical volume of "<2.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/md0
  VG Name
  PV Size               <2.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               KlLUGd-oozm-AmN3-bJzI-pYpD-qhXl-GuQFbP

  "/dev/md1" is a new physical volume of "1018.00 MiB"
  --- NEW Physical volume ---
  PV Name               /dev/md1
  VG Name
  PV Size               1018.00 MiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               4Ltx99-kdbW-R6ks-57QF-vPof-0VMH-PUxh3X
```
9. Создайте общую volume-group на этих двух PV
```
root@vagrant:~# vgcreate vgArray /dev/md{0,1}
  Volume group "vgArray" successfully created
```

```
root@vagrant:~# root@vagrant:~# vgs
  VG        #PV #LV #SN Attr   VSize   VFree
  ubuntu-vg   1   1   0 wz--n- <62.50g 31.25g
  vgArray     2   0   0 wz--n-  <2.99g <2.99g
```
10. **Создайте LV размером 100 Мб, указав его расположение на PV с RAID0**
```
root@vagrant:~# lvcreate -L 100M vgArray /dev/md1 -n lv100M
Logical volume "lv100M" created.
```
11. **Создайте mkfs.ext4 ФС на получившемся LV**
```
root@vagrant:~# mkfs.ext4 /dev/vgArray/lv100M
```

```
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 25600 4k blocks and 25600 inodes

Allocating group tables: done
Writing inode tables: done
Creating journal (1024 blocks): done
Writing superblocks and filesystem accounting information: done
```
12. **Смонтируйте этот раздел в любую директорию, например, /tmp/new**
```
root@vagrant:~# mkdir /tmp/new
root@vagrant:~# mount /dev/vgArray/lv100M /tmp/new/
```
13. **Поместите туда тестовый файл, например wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz**
```
wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz
```
14. **Вывод lsblk**
```
root@vagrant:~# lsblk | grep -v loop*
NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                         8:0    0   64G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0  1.5G  0 part  /boot
└─sda3                      8:3    0 62.5G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.3G  0 lvm   /
sdb                         8:16   0  2.5G  0 disk
├─sdb1                      8:17   0    2G  0 part
│ └─md0                     9:0    0    2G  0 raid1
└─sdb2                      8:18   0  511M  0 part
  └─md1                     9:1    0 1018M  0 raid0
    └─vgArray-lv100M      253:1    0  100M  0 lvm   /tmp/new
sdc                         8:32   0  2.5G  0 disk
├─sdc1                      8:33   0    2G  0 part
│ └─md0                     9:0    0    2G  0 raid1
└─sdc2                      8:34   0  511M  0 part
  └─md1                     9:1    0 1018M  0 raid0
    └─vgArray-lv100M      253:1    0  100M  0 lvm   /tmp/new
```
15. **Протестируйте целостность файла**
```
root@vagrant:~# gzip -t /tmp/new/test.gz
root@vagrant:~# echo $?
0
```
16. **Используя pvmove, переместите содержимое PV с RAID0 на RAID1**
```
root@vagrant:~# pvmove /dev/md1
  /dev/md1: Moved: 16.00%
  /dev/md1: Moved: 100.00%
```
17. **Сделайте --fail на устройство в вашем RAID1 md**
```
root@vagrant:~# mdadm /dev/md0 --fail /dev/sdb1
mdadm: set /dev/sdb1 faulty in /dev/md0
```

```
root@vagrant:~# root@vagrant:~# mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Sat Sep 17 19:23:39 2022
        Raid Level : raid1
        Array Size : 2094080 (2045.00 MiB 2144.34 MB)
     Used Dev Size : 2094080 (2045.00 MiB 2144.34 MB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

       Update Time : Mon Sep 19 11:15:32 2022
             State : clean, degraded
    Active Devices : 1
   Working Devices : 1
    Failed Devices : 1
     Spare Devices : 0

Consistency Policy : resync

              Name : vagrant:0  (local to host vagrant)
              UUID : e3e723ce:7bca9bcb:71798dd9:bfe1e81a
            Events : 19

    Number   Major   Minor   RaidDevice State
       -       0        0        0      removed
       1       8       33        1      active sync   /dev/sdc1

       0       8       17        -      faulty   /dev/sdb1
```
18. **Подтвердите выводом dmesg, что RAID1 работает в деградированном состоянии**
```
root@vagrant:~# dmesg | grep md0
[12152.329815] md/raid1:md0: not clean -- starting background reconstruction
[12152.329817] md/raid1:md0: active with 2 out of 2 mirrors
[12152.329832] md0: detected capacity change from 0 to 2144337920
[12152.332139] md: resync of RAID array md0
[12162.995978] md: md0: resync done.
[27357.525150] md/raid1:md0: Disk failure on sdb1, disabling device.
               md/raid1:md0: Operation continuing on 1 devices.
```
19. **Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:**
```
root@vagrant:~# gzip -t /tmp/new/test.gz
root@vagrant:~# echo $?
0
```
20. **Погасите тестовый хост**
```
vagrant destroy
```
*Это конец...*

