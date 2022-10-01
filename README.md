## Компьютерные сети (лекция 2) ##  

**1. Проверьте список доступных сетевых интерфейсов на вашем компьютере. Какие команды есть для этого в Linux и в Windows?**  

В Windows для этого в командной строке набрать `ipconfig /all` 

Команда отображает полную конфигурацию TCP/IP для всех адаптеров. Адаптеры могут представлять физические интерфейсы, такие как установленные сетевые адаптеры, или логические интерфейсы, такие как подключения удаленного доступа.

В Linux системах есть утилита `ip`, которая с параметром `address` (или сокращенно `addr` и даже `a`) покажет сетевые интерфейсы с их параметрами.  
```
jenkidu@netology:~$ ip ad
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:f6:40:5a brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 metric 100 brd 10.0.2.255 scope global dynamic enp0s3
       valid_lft 85775sec preferred_lft 85775sec
    inet6 fe80::a00:27ff:fef6:405a/64 scope link 
       valid_lft forever preferred_lft forever
```
P.S. и старая добрая ifconfig в зависимости от дистрибутива и выбора установки.  

**2. Какой протокол используется для распознавания соседа по сетевому интерфейсу? Какой пакет и команды есть в Linux для этого?**  
Для этого существует **Link Layer Discovery Protocol (LLDP)** — протокол канального уровня, позволяющий сетевому оборудованию оповещать оборудование, работающее в локальной сети, о своём существовании и передавать ему свои характеристики, а также получать от него аналогичные сведения.  
Используется демон `lldpd` из пакета `lldpd`  

**3. Какая технология используется для разделения L2 коммутатора на несколько виртуальных сетей? Какой пакет и команды есть в Linux для этого? Приведите пример конфига.**  
Для этого используется технология **VLAN** - она работает на канальном уровне модели OSI.
Чтобы в Linux настраивать/управлять vlan, должен быть загружен драйвер (модуль) ядра под названием 8021
Способы создания vlan в linux:  
- Создать конфиг в `/etc/neplan/*` наподобие:  
```
# Конфигурация VLAN с ID 100 для интерфейса enp1s3 
iface enp0s3.100 inet static 
address 10.0.2.20 
netmask 255.255.255.0 
vlan-raw-device enp0s3
```
`auto enp0s3.100` — «поднимать» интерфейс при запуске сетевой службы  
`iface enp0s3.100` — название интерфейса  
`vlan-raw-device`— указывает на каком физическом интерфейсе создавать VLAN  

- Также существует команда vconfig. 

a) сначала ставим пакет  
```
sudo apt install vlan
```
b) Настройка  
Создаю новый интерфейс, который является членом определенной VLAN, в этом примере  идентификатор VLAN 10. Можно использовать только физические интерфейсы в качестве базы, создание VLAN на виртуальных интерфейсах не будет работать. В этом примере мы используем физический интерфейс `enp0s3`. Эта команда добавит дополнительный интерфейс рядом с уже настроенным интерфейсом, поэтому существующая конфигурация `enp0s3` не пострадает.
```
jenkidu@netology:~$ sudo vconfig add enp0s3 10
```

```
jenkidu@netology:~$ sudo ip link add link enp0s3 name enp0s3.10 type vlan id 10
```
Назначаю адрес новому интерфейсу:
```
jenkidu@netology:~$ sudo ip ad add 10.0.0.1/24 dev enp0s3.10
```
Запускаю:
```
jenkidu@netology:~$ sudo ip link set up enp0s3.10
```

```
jenkidu@netology:~$ ip a | grep -v lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:f6:40:5a brd ff:ff:ff:ff:ff:ff
       valid_lft 86292sec preferred_lft 86292sec
    inet6 fe80::a00:27ff:fef6:405a/64 scope link 
       valid_lft forever preferred_lft forever
3: enp0s3.10@enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:f6:40:5a brd ff:ff:ff:ff:ff:ff
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fef6:405a/64 scope link 
       valid_lft forever preferred_lft forever
```
Все это до следующей перезагрузки, перманентным этот интерфейс делать не стал.  

**4. Какие типы агрегации интерфейсов есть в Linux? Какие опции есть для балансировки нагрузки? Приведите пример конфига.**  
В Linux это называется *bonding*:  

`mode=0 (balance-rr)`  Этот режим используется по умолчанию, если в настройках не указано другое. balance-rr обеспечивает балансировку нагрузки и отказоустойчивость. В данном режиме пакеты отправляются "по кругу" от первого интерфейса к последнему и сначала. Если выходит из строя один из интерфейсов, пакеты отправляются на остальные оставшиеся. При подключении портов к разным коммутаторам, требует их настройки.  

`mode=1 (active-backup)`  При active-backup один интерфейс работает в активном режиме, остальные в ожидающем. Если активный падает, управление передается одному из ожидающих. Не требует поддержки данной функциональности от коммутатора.  

`mode=2 (balance-xor)`  
Передача пакетов распределяется между объединенными интерфейсами по формуле ((MAC-адрес источника) XOR (MAC-адрес получателя)) % число интерфейсов. Один и тот же интерфейс работает с определённым получателем. Режим даёт балансировку нагрузки и отказоустойчивость.  

`mode=3 (broadcast)`  Происходит передача во все объединенные интерфейсы, обеспечивая отказоустойчивость.  

`mode=4 (802.3ad)`  Это динамическое объединение портов. В данном режиме можно получить значительное увеличение пропускной способности как входящего так и исходящего трафика, используя все объединенные интерфейсы. Требует поддержки режима от коммутатора, а так же (иногда) дополнительную настройку коммутатора.  

`mode=5 (balance-tlb)`
Адаптивная балансировка нагрузки. При balance-tlb входящий трафик получается только активным интерфейсом, исходящий - распределяется в зависимости от текущей загрузки каждого интерфейса. Обеспечивается отказоустойчивость и распределение нагрузки исходящего трафика. Не требует специальной поддержки коммутатора.  

`mode=6 (balance-alb)`
Адаптивная балансировка нагрузки (более совершенная). Обеспечивает балансировку нагрузки как исходящего (TLB, transmit load balancing), так и входящего трафика (для IPv4 через ARP). Не требует специальной поддержки коммутатором, но требует возможности изменять MAC-адрес устройства.  

У меня был опыт настройки файлового сервера на Ubuntu 18, там я использовал ``balance-rr``, вот его конфиг:  

```
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
version: 2
renderer: networkd
ethernets:
  enp1s0:
    dhcp4: false
    dhcp6: false
  enp2s0:
    dhcp4: false
    dhcp6: false
bonds:
  bond0:
   dhcp4: false
   dhcp6: false
   interfaces:
     - enp1s0
     - enp2s0
   addresses: [10.1.0.18/16]
   gateway4: 10.1.0.2
   parameters:
     mode: balance-rr
   nameservers:
     search: [domain.local]
     addresses: [10.1.0.1,10.1.0.101]
```

**5. Сколько IP адресов в сети с маской /29 ? Сколько /29 подсетей можно получить из сети с маской /24. Приведите несколько примеров /29 подсетей внутри сети 10.10.10.0/24.**  
```
jenkidu@netology:~$ ipcalc -b 10.0.2.15/29
Address:   10.0.2.15            
Netmask:   255.255.255.248 = 29 
Wildcard:  0.0.0.7              
=>
Network:   10.0.2.8/29          
HostMin:   10.0.2.9             
HostMax:   10.0.2.14            
Broadcast: 10.0.2.15            
Hosts/Net: 6                     Class A, Private Internet
```
Всего 8 адресов: 6 адресов для хостов, 1 адрес широковещательный, 1 адрес сети.  

В сети /24 можно получить 32 подсети /29, так как 256/8=32 (кол-во адресов в каждой сети).  

**6. Задача: вас попросили организовать стык между 2-мя организациями. Диапазоны 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 уже заняты. Из какой подсети допустимо взять частные IP адреса? Маску выберите из расчета максимум 40-50 хостов внутри подсети.**  
Как было сказано на лекции, недопустимо внутри локальной сети использовать чужие публичные адреса, поэтому были созданы  указанные выше диапазоны для работы внутри сети. И если они заняты, то нужно воспользоваться технологией CG-NAT  
Пример подсети:
100.64.0.0/27

**7. Как проверить ARP таблицу в Linux, Windows? Как очистить ARP кеш полностью? Как из ARP таблицы удалить только один нужный IP?**  
В Windows в командной строке с правами администратора:  
`arp -a` - просмотреть таблицу  
`arp -d` - очистка таблицы  
`arp -d <ip_address>` - очистка конкретного IP-адреса  

В Linux используется команда `ip`:  
`ip -s -s neigh flush all` - очистить всю таблицу  
`arp -d <ip_address>` - очистка конкретного IP-адреса  
`arp -n` - посмотреть таблицу  

*Это конец...*

