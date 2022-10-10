## 3.8 Компьютерные сети, лекция 3 ##  
---
1. **Подключитесь к публичному маршрутизатору в интернет. Найдите маршрут к вашему публичному IP**  
```
telnet route-views.routeviews.org
Username: rviews
show ip route x.x.x.x/32
show bgp x.x.x.x/32
```

```
Username: rviews
route-views>show ip route x.x.249.179
Routing entry for x.x.249.0/24
  Known via "bgp 6447", distance 20, metric 0
  Tag 3356, type external
  Last update from 4.68.4.46 1d09h ago
  Routing Descriptor Blocks:
  * 4.68.4.46, from 4.68.4.46, 1d09h ago
      Route metric is 0, traffic share count is 1
      AS Hops 3
      Route tag 3356
      MPLS label: none
```

```
route-views>show bgp x.x.249.179
BGP routing table entry for x.x.249.0/24, version 2458153267
Paths: (22 available, best #8, table default)
  Not advertised to any peer
  Refresh Epoch 1
  3267 1299 9002 51765
    194.85.40.15 from 194.85.40.15 (185.141.126.1)
      Origin IGP, metric 0, localpref 100, valid, external
      path 7FE121210118 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  3333 9002 51765
    193.0.0.56 from 193.0.0.56 (193.0.0.56)
      Origin IGP, localpref 100, valid, external
      path 7FDFFB95B5E0 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  7018 174 51765
    12.0.1.63 from 12.0.1.63 (12.0.1.63)
      Origin IGP, localpref 100, valid, external
      Community: 7018:5000 7018:37232
      path 7FE005C9C158 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  6939 9002 51765
    64.71.137.241 from 64.71.137.241 (216.218.252.164)
      Origin IGP, localpref 100, valid, external
      path 7FE161B4CD40 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  57866 9002 51765
    37.139.139.17 from 37.139.139.17 (37.139.139.17)
      Origin IGP, metric 0, localpref 100, valid, external
      Community: 9002:0 9002:64623 57866:100 65100:9002 65103:1 65104:31
      unknown transitive attribute: flag 0xE0 type 0x20 length 0x30
        value 0000 E20A 0000 0064 0000 232A 0000 E20A
              0000 0065 0000 0064 0000 E20A 0000 0067
              0000 0001 0000 E20A 0000 0068 0000 001F
```

2. **Создайте dummy0 интерфейс в Ubuntu. Добавьте несколько статических маршрутов. Проверьте таблицу маршрутизации.**  


Загрузил модуль dummy:  
```
root@netology:~# modprobe dummy
```

создал этот виртуальный интерфейс:  
```
root@netology:~# modprobe -v dummy numdummies=2
```

Присвоил ip адрес интерфейсу:  
```
root@netology:~# ip link add dummy0 type dummy
root@netology:~# ip addr add 10.0.2.20/24 dev dummy0
```

```
root@netology:~# ifconfig -a | grep dummy
dummy0: flags=130<BROADCAST,NOARP>  mtu 1500
```

создал файл `dummy.conf` и записал туда инфу о количестве интерфейсов  
```
root@netology:~# cat /etc/modprobe.d/dummy.conf 
options dummy numdummies=2
```

Запись маршрута:  
```
root@netology:~# ip route add 8.8.8.8 via 10.0.2.20
```

Просмотр таблицы маршрутизации:  
```
root@netology:~# netstat -rn 
Kernel IP routing table 
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface 
0.0.0.0         10.0.2.2        0.0.0.0         UG        0 0          0 enp0s3 
8.8.8.8         10.0.2.20       255.255.255.255 UGH       0 0          0 dummy0 
10.0.2.0        0.0.0.0         255.255.255.0   U         0 0          0 dummy0 
10.0.2.0        0.0.0.0         255.255.255.0   U         0 0          0 enp0s3 
10.0.2.2        0.0.0.0         255.255.255.255 UH        0 0          0 enp0s3 
10.0.2.20       10.0.2.15       255.255.255.255 UGH       0 0          0 enp0s3 
10.183.0.1      10.0.2.2        255.255.255.255 UGH       0 0          0 enp0s3
```

3. **Проверьте открытые TCP порты в Ubuntu, какие протоколы и приложения используют эти порты? Приведите несколько примеров.**  

```
root@netology:~# ss -ntlp | grep LISTEN
LISTEN 0      4096   127.0.0.53%lo:53        0.0.0.0:*    users:(("systemd-resolve",pid=641,fd=14))
LISTEN 0      128          0.0.0.0:22        0.0.0.0:*    users:(("sshd",pid=709,fd=3))            
LISTEN 0      128        127.0.0.1:6010      0.0.0.0:*    users:(("sshd",pid=1008,fd=9))           
LISTEN 0      128             [::]:22           [::]:*    users:(("sshd",pid=709,fd=4))            
LISTEN 0      128            [::1]:6010         [::]:*    users:(("sshd",pid=1008,fd=7))           
LISTEN 0      4096               *:9090            *:*    users:(("prometheus",pid=862,fd=8))
```
- 53 - DNS  
- 22 - SSH  
- 9090 - установленный из предыдущих ДЗ node_exporter  
- 6010 - порт, связанный с функцией переадресации X11 в ssh.  

4. **Проверьте используемые UDP сокеты в Ubuntu, какие протоколы и приложения используют эти порты?**  
```
root@netology:~# ss -lunp
```
| State       |     Recv-Q    |  Send-Q  |  Local Address:Port | Peer Address:Port  |  Process  | 
|------------|---------------|-------------|---------------------------|--------------------------|--------------------------------------------------------|                                            
| UNCONN |          0          |     0              |      127.0.0.53%lo:53  |                        0.0.0.0: *|                 users:(("systemd-resolve",pid=641,fd=13))  |           
| UNCONN  |         0          |     0              |      10.0.2.15%enp0s3:68 |                0.0.0.0: *  |               users:(("systemd-network",pid=1429,fd=18))|  

`-l` - прослушиваемые порты  
`-u` - UDP-сокеты  
`-n` - не пытаться разрешить в имена служб (чтоб показал именно порт)  
`-p` - показать процесс, который использует сокет  

- 53 - DNS  
- 68 - используются DHCP-сервером для назначения IP-адресов  

5. **Используя diagrams.net, создайте L3 диаграмму вашей домашней сети или любой другой сети, с которой вы работали.**  

[my_homework_net](https://disk.yandex.ru/i/I3mk5-yJi29U9Q)

Поменьше функционала, чем у MS Visio, зато бесплатная. Для небольших задач - супер!

_Это конец..._


