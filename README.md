## 3.6. Компьютерные сети, лекция 1 ##  

1. **Работа c HTTP через телнет**
```
root@netology:~# telnet stackoverflow.com 80 
Trying 151.101.129.69... 
Connected to stackoverflow.com. 
Escape character is '^]'. 

GET /questions HTTP/1.0 
HOST: stackoverflow.com 

HTTP/1.1 301 Moved Permanently 
Server: Varnish 
Retry-After: 0 
Location: https://stackoverflow.com/questions 
Content-Length: 0 
Accept-Ranges: bytes 
Date: Thu, 22 Sep 2022 13:37:52 GMT 
Via: 1.1 varnish 
Connection: close 
X-Served-By: cache-fra19175-FRA 
X-Cache: HIT 
X-Cache-Hits: 0 
X-Timer: S1663853872.425953,VS0,VE0 
Strict-Transport-Security: max-age=300 
X-DNS-Prefetch-Control: off 
Connection closed by foreign host.
```
Код ответа 301 (moved permanently) говорит о том, что ресурс перемещен на постоянной основе на новое место (поле Location). Это логично, так как "стучусь" по 80 порту. Чтоб было больше информации, можно использовать при запросе openssl.
2. **Повторите задание 1 в браузере, используя консоль разработчика F12.**
- откройте вкладку Network
- отправьте запрос [http://stackoverflow.com](http://stackoverflow.com)
- найдите первый ответ HTTP сервера, откройте вкладку Headers
- укажите в ответе полученный HTTP код.
- проверьте время загрузки страницы, какой запрос обрабатывался дольше всего?
- приложите скриншот консоли браузера в ответ.  

[Скрин_1](https://disk.yandex.ru/i/5eeVefBS7mLW3Q)  
Первый ответ с кодом 307 Internal Redirect, так как сейчас все современные браузеры перенаправляют с http на https. 

[Скрин_2](https://disk.yandex.ru/i/urF-Q3Cg5lB_wg)   
Дольше всего обрабатывался запрос открытия страницы (документа). Время загрузки страницы 1.07 сек.

3. **Какой IP адрес у вас в интернете?**
```
jenkidu@netology:~$ wget -qO- eth0.me
95.73.X.X
```
Получил с внешнего ресурса eth0.me информацию. Опция -q чтоб не выводить сообщения wget, опция -O- выводить значения в стандартный stdout вместо файла.
4. **Какому провайдеру принадлежит ваш IP адрес? Какой автономной системе AS? Воспользуйтесь утилитой whois**
```
jenkidu@netology:~$ whois 95.73.X.X |  grep descr
descr:          Pushkino Flate rate pool
descr:          Rostelecom networks
```

```
jenkidu@netology:~$ whois 95.73.X.X |  grep AS
% Information related to '95.73.40.0/21AS12389'
origin:         AS12389
```
А еще нашел вот такую интересную конструкцию с dig:
```
jenkidu@netology:~$ dig $(dig -x 95.73.X.X | grep PTR | tail -n 1 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}').origin.asn.cymru.com TXT +short
"12389 | 95.73.40.0/21 | RU | ripencc | 2008-11-28"
```
5. **Через какие сети проходит пакет, отправленный с вашего компьютера на адрес 8.8.8.8? Через какие AS? Воспользуйтесь утилитой traceroute**
```
jenkidu@netology:~$ traceroute -AI 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  _gateway (10.0.2.2) [*]  0.772 ms  0.726 ms  0.714 ms
 2  router.asus.com (192.168.1.1) [*]  5.036 ms  5.697 ms  5.686 ms
 3  ipoe-static.mosoblast.rt.ru (213.140.228.144) [AS25515]  5.670 ms  6.311 ms  6.225 ms
 4  188.254.15.141 (188.254.15.141) [AS12389]  6.872 ms  7.633 ms  7.622 ms
 5  185.140.148.153 (185.140.148.153) [AS12389]  10.176 ms  10.165 ms  10.155 ms
 6  72.14.209.89 (72.14.209.89) [AS15169]  9.429 ms  7.844 ms  8.347 ms
 7  108.170.250.33 (108.170.250.33) [AS15169]  11.796 ms  10.659 ms  11.254 ms
 8  108.170.250.34 (108.170.250.34) [AS15169]  11.220 ms  11.199 ms  11.178 ms
 9  172.253.66.116 (172.253.66.116) [AS15169]  26.641 ms  27.074 ms  27.032 ms
10  172.253.65.159 (172.253.65.159) [AS15169]  27.004 ms  26.983 ms  26.962 ms
11  216.239.62.13 (216.239.62.13) [AS15169]  27.550 ms  27.370 ms  24.259 ms
12  * * *
13  * * *
14  * * *
15  * * *
16  * * *
17  * * *
18  * * *
19  * * *
20  * * *
21  dns.google (8.8.8.8) [AS15169]  25.777 ms  26.626 ms  26.621 ms
```
6. **Повторите задание 5 в утилите mtr. На каком участке наибольшая задержка - delay?**
```
jenkidu@netology:~$ mtr 8.8.8.8 -znrc 1
Start: 2022-09-24T16:03:54+0000
HOST: netology                    Loss%   Snt   Last   Avg  Best  Wrst StDev
  1. AS???    10.0.2.2             0.0%     1    0.9   0.9   0.9   0.9   0.0
  2. AS???    192.168.140.139      0.0%     1   12.4  12.4  12.4  12.4   0.0
  3. AS???    ???                 100.0     1    0.0   0.0   0.0   0.0   0.0
  4. AS???    ???                 100.0     1    0.0   0.0   0.0   0.0   0.0
  5. AS???    ???                 100.0     1    0.0   0.0   0.0   0.0   0.0
  6. AS???    ???                 100.0     1    0.0   0.0   0.0   0.0   0.0
  7. AS???    ???                 100.0     1    0.0   0.0   0.0   0.0   0.0
  8. AS???    ???                 100.0     1    0.0   0.0   0.0   0.0   0.0
  9. AS31133  78.25.80.93          0.0%     1   46.4  46.4  46.4  46.4   0.0
 10. AS31133  78.25.80.92          0.0%     1   45.9  45.9  45.9  45.9   0.0
 11. AS31133  37.29.17.87          0.0%     1   45.4  45.4  45.4  45.4   0.0
 12. AS15169  74.125.244.132       0.0%     1   52.8  52.8  52.8  52.8   0.0
 13. AS15169  72.14.232.85         0.0%     1   47.4  47.4  47.4  47.4   0.0
 14. AS15169  142.251.51.187       0.0%     1   48.1  48.1  48.1  48.1   0.0
 15. AS15169  172.253.70.51        0.0%     1   45.9  45.9  45.9  45.9   0.0
 16. AS???    ???                 100.0     1    0.0   0.0   0.0   0.0   0.0
```
Наибольшая задержка на AS AS15169 (принадлежит гуглу)  
Тут другие адреса, так как я начал делать задание с одним внешним IP, а продолжаю через мобильный интернет.
7. **Какие DNS сервера отвечают за доменное имя dns.google? Какие A записи? воспользуйтесь утилитой dig**
```
jenkidu@netology:~$ dig dns.google NS +short
ns1.zdns.google.
ns2.zdns.google.
ns4.zdns.google.
ns3.zdns.google.
```
опция +short для краткого вывода по NS-записям запрашиваемого ресурса.

```
jenkidu@netology:~$ dig dns.google A +short
8.8.4.4
8.8.8.8
```
А-записи dns.google
8. **Проверьте PTR записи для IP адресов из задания 7. Какое доменное имя привязано к IP? воспользуйтесь утилитой dig**
```
jenkidu@netology:~$ for ip in `dig +short A dns.google`; do dig -x $ip | grep ^[0-9].*in-addr; done
8.8.8.8.in-addr.arpa.	7144	IN	PTR	dns.google.
4.4.8.8.in-addr.arpa.	7064	IN	PTR	dns.google.
```
_Это конец..._
