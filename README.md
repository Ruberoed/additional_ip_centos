### additional_ip_centos

Допомагає автоматизувати процес додавання додаткових ір адресс у CentOS
1. Копіюємо репозиторій 
```git clone https://github.com/Ruberoed/additional_ip_centos/```
2. Переміщуємось у папку: 
```cd additional_ip_centos```
3. Переписуємо файл ```./ip_example.txt``` додаючи свої адреси  
4. Запускаємо сценарій: 
```bash script.sh /etc/sysconfig/networks/scripts/<інтерфейс> ip_example.txt```
5. перевіряємо конфігурацію: 
```ip a```
