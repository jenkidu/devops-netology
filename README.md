### **Домашнее задание "Операционные системы. Лекция 2.**
1. **На пекции мы познакомились с `node_exporter`**...  
+ поместите его в автозагрузку,  
+ предусмотрите возможность добавления опций к запускаемому процессу через внешний файл (посмотрите, например, на `systemctl cat cron`),  
+ удостоверьтесь, что с помощью systemctl процесс корректно стартует, завершается, а после перезагрузки автоматически поднимается.

**Ответ:** Конфиг юнита  
`$ cat /etc/systemd/system/node_exporter.service`  
[Unit]  
Description=Prometheus Node Exporter  
Wants=network-online.target  
After=network-online.target  

[Service]  
Type=simple  
ExecStart=/usr/local/bin/node_exporter   
EnvironmentFile=/etc/default/node_exporter  

[Install]  
WantedBy=multi-user.target  

Поместить в автозагрузку и проверить статус  
`$ sudo systemctl daemon-reload`  
`$ sudo systemctl enable --now node_exporter`  
`$ sudo systemctl status node_exporter`  
Вывод  
`node_exporter.service - Prometheus Node Exporter  
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)  
     Active: active (running) since Mon 2022-01-10 18:23:37 UTC; 8min ago
   Main PID: 4501 (node_exporter)  
      Tasks: 5 (limit: 2240)  
     Memory: 4.5M  
     CGroup: /system.slice/node_exporter.service
             └─4501 /usr/local/bin/node_exporter`  
Процесс запускается после перезапуска (процесса, системы)  
[Ссылка на скрин с браузера](https://disk.yandex.ru/i/PR4oMzvrN50LPg)

---
2. **Ознакомьтесь с опциями node_exporter и выводом /metrics по-умолчанию. Приведите несколько опций, которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.**

**Ответ:**  
**CPU:**  
node_cpu_seconds_total{cpu="0",mode="idle"} 43188.26  
node_cpu_seconds_total{cpu="0",mode="iowait"} 11.76  
node_cpu_seconds_total{cpu="0",mode="irq"} 0  
node_cpu_seconds_total{cpu="0",mode="nice"} 13.39  

**memory**  
node_memory_MemFree_bytes 1.33607424e+08  
node_memory_MemTotal_bytes 2.049941504e+09

**Disk**  
_время на операции ввода/вывода_  
node_disk_io_time_seconds_total{device="dm-0"} 146.536  
node_disk_io_time_seconds_total{device="sda"} 148.816  
node_disk_io_time_seconds_total{device="sr0"} 0.232  
node_disk_io_time_seconds_total{device="sr1"} 1.328  
_время, потраченное на операции чтения_  
node_disk_read_time_seconds_total{device="dm-0"} 35.78  
node_disk_read_time_seconds_total{device="sda"} 22.721  
node_disk_read_time_seconds_total{device="sr0"} 0.146  
node_disk_read_time_seconds_total{device="sr1"} 1.249  
_время, потраченное на операции записи_  
node_disk_write_time_seconds_total{device="dm-0"} 236.644  
node_disk_write_time_seconds_total{device="sda"} 116.42  
node_disk_write_time_seconds_total{device="sr0"} 0  
node_disk_write_time_seconds_total{device="sr1"} 0  

**Сеть**  
node_network_transmit_packets_total{device="ens33"} 77641  
node_network_transmit_bytes_total{device="ens33"} 8.492856e+06  

---
3. **Установите в свою виртуальную машину Netdata...**  
+ в конфигурационном файле /etc/netdata/netdata.conf в секции [web] замените значение с localhost на bind to = 0.0.0.0,  
+ добавьте в Vagrantfile проброс порта Netdata на свой локальный компьютер и сделайте vagrant reload:  
```config.vm.network "forwarded_port", guest: 19999, host: 19999```

**Ответ:**  
Установил, изменил конфиг, пробросил порт, ознакомился с метриками - [выглядит приятно и информативно.](https://disk.yandex.ru/i/vWZiGjrGyKvRSQ)  

---

4. **Можно ли по выводу ```dmesg``` понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?**

Ответ:  да, еще и определяет, что за гипервизор
```sudo dmesg | grep "Hypervisor detected"```  
```Hypervisor detected: VMware```

---
5. **Как настроен ```sysctl fs.nr_open``` на системе по-умолчанию? Узнайте, что означает этот параметр. Какой другой существующий лимит не позволит достичь такого числа (```ulimit --help```)?**

**Ответ:** 
```/sbin/sysctl -n fs.nr_open```  
```1048576```  
Этот параметр (```nr_open```) означает количество файлов, которые могут быть выделены одним процессом  
Количество файловых дескрипторов, открытых всеми процессами, не может превышать ```/proc/sys/fs/file-max```  
Количество файловых дескрипторов, открытых одним процессом, не может превышать мягкое ограничение nofile в пользовательском ограничении  
```ulimit -Sn``` - мягкий лимит на пользователя (можно изменить)  
```ulimit -Hn``` - жесткий лимит на пользователя (нельзя увеличить, только уменьшить)  

---
6. **Запустите любой долгоживущий процесс (не ```ls```, который отработает мгновенно, а, например, ```sleep 1h```) в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через ```nsenter```. Для простоты работайте в данном задании под root (```sudo -i```). Под обычным пользователем требуются дополнительные опции (```--map-root-user```) и т.д.**

**Ответ:**  
```jenkidu@netology:~$ ps -e | grep sleep```  
   ```2270 pts/1    00:00:00 sleep```  
```jenkidu@netology:~$ sudo -i```  
```root@netology:~# nsenter --target 2270 --pid --mount --no-fork```  
```root@netology:/# ps```  
    ```PID TTY          TIME CMD```  
   ```2358 pts/0    00:00:00 sudo```  
   ```2359 pts/0    00:00:00 bash```  
   ```2372 pts/0    00:00:00 bash```  
   ```2387 pts/0    00:00:00 ps```  
   
   ---

7. **Найдите информацию о том, что такое ```:(){ :|:& };:```**...  

**Ответ:** Это так называемая форк-бомба. Команда оперирует определением функции с именем ‘:‘, которая вызывает сама себя дважды: один раз на переднем плане и один раз в фоне. Она продолжает своё выполнение снова и снова, пока система не зависнет.  
Судя по логу ```dmesg```, стабилизировалось все  
```[19351.581437] cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-44.scope```  
Дело опять же в ```ulimit``` - он не позволяет нежелательным процессам поглощать системные ресурсы  
Изменить число процессов по умолчанию можно командой  
```ulimit -u 30 ``` - ограничит число процессов для пользователя до 30.

---
*Это  конец...*

