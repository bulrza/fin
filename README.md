
#  Дипломная работа по профессии «Системный администратор» - Булюшкин Александр

Содержание
==========
- [Дипломная работа по профессии «Системный администратор» - Булюшкин Александр](#дипломная-работа-по-профессии-системный-администратор---булюшкин-александр)
- [Содержание](#содержание)
  - [Задача](#задача)
  - [Инфраструктура](#инфраструктура)
    - [Сайт](#сайт)
    - [Мониторинг](#мониторинг)
    - [Логи](#логи)
    - [Сеть](#сеть)
    - [Резервное копирование](#резервное-копирование)
    - [Дополнительно](#дополнительно)
  - [Выполнение работы](#выполнение-работы)
    - [Развертывание инфраструктуры в Yandex Cloud](#развертывание-инфраструктуры-в-yandex-cloud)
    - [Настройка серверов с помощью Ansible](#настройка-серверов-с-помощью-ansible)
	


---------

## Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/) и отвечать минимальным стандартам безопасности: запрещается выкладывать токен от облака в git. Используйте [инструкцию](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#get-credentials).

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

## Инфраструктура
Для развёртки инфраструктуры используйте Terraform и Ansible.  

Не используйте для ansible inventory ip-адреса! Вместо этого используйте fqdn имена виртуальных машин в зоне ".ru-central1.internal". Пример: example.ru-central1.internal  - для этого достаточно при создании ВМ указать name=example, hostname=examle !! 

Важно: используйте по-возможности **минимальные конфигурации ВМ**:2 ядра 20% Intel ice lake, 2-4Гб памяти, 10hdd, прерываемая. 

**Так как прерываемая ВМ проработает не больше 24ч, перед сдачей работы на проверку дипломному руководителю сделайте ваши ВМ постоянно работающими.**

Ознакомьтесь со всеми пунктами из этой секции, не беритесь сразу выполнять задание, не дочитав до конца. Пункты взаимосвязаны и могут влиять друг на друга.

### Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.

Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

Виртуальные машины не должны обладать внешним Ip-адресом, те находится во внутренней сети. Доступ к ВМ по ssh через бастион-сервер. Доступ к web-порту ВМ через балансировщик yandex cloud.

Настройка балансировщика:

1. Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.

2. Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.

3. Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите — /, backend group — созданную ранее.

4. Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

Протестируйте сайт
`curl -v <публичный IP балансера>:80` 

### Мониторинг
Создайте ВМ, разверните на ней Zabbix. На каждую ВМ установите Zabbix Agent, настройте агенты на отправление метрик в Zabbix. 

Настройте дешборды с отображением метрик, минимальный набор — по принципу USE (Utilization, Saturation, Errors) для CPU, RAM, диски, сеть, http запросов к веб-серверам. Добавьте необходимые tresholds на соответствующие графики.

### Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

### Сеть
Разверните один VPC. Сервера web, Elasticsearch поместите в приватные подсети. Сервера Zabbix, Kibana, application load balancer определите в публичную подсеть.

Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh.  Эта вм будет реализовывать концепцию  [bastion host]( https://cloud.yandex.ru/docs/tutorials/routing/bastion) . Синоним "bastion host" - "Jump host". Подключение  ansible к серверам web и Elasticsearch через данный bastion host можно сделать с помощью  [ProxyCommand](https://docs.ansible.com/ansible/latest/network/user_guide/network_debug_troubleshooting.html#network-delegate-to-vs-proxycommand) . Допускается установка и запуск ansible непосредственно на bastion host.(Этот вариант легче в настройке)

Исходящий доступ в интернет для ВМ внутреннего контура через [NAT-шлюз](https://yandex.cloud/ru/docs/vpc/operations/create-nat-gateway).

### Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

### Дополнительно
Не входит в минимальные требования. 

1. Для Zabbix можно реализовать разделение компонент - frontend, server, database. Frontend отдельной ВМ поместите в публичную подсеть, назначте публичный IP. Server поместите в приватную подсеть, настройте security group на разрешение трафика между frontend и server. Для Database используйте [Yandex Managed Service for PostgreSQL](https://cloud.yandex.com/en-ru/services/managed-postgresql). Разверните кластер из двух нод с автоматическим failover.
2. Вместо конкретных ВМ, которые входят в target group, можно создать [Instance Group](https://cloud.yandex.com/en/docs/compute/concepts/instance-groups/), для которой настройте следующие правила автоматического горизонтального масштабирования: минимальное количество ВМ на зону — 1, максимальный размер группы — 3.
3. В Elasticsearch добавьте мониторинг логов самого себя, Kibana, Zabbix, через filebeat. Можно использовать logstash тоже.
4. Воспользуйтесь Yandex Certificate Manager, выпустите сертификат для сайта, если есть доменное имя. Перенастройте работу балансера на HTTPS, при этом нацелен он будет на HTTP веб-серверов.

## Выполнение работы

### Развертывание инфраструктуры в Yandex Cloud
Для развертывания инфраструктуры в облаке Яндекс используется **terraform**. Необходимо установить **terraform** а так же **yandex console**, задать переменные среды для облака Яндекс:  
ID облака, ID каталога и токен для приложения. Для Windows PowerShell это:
```
$Env:YC_TOKEN=$(yc iam create-token)
$Env:YC_CLOUD_ID=$(yc config get cloud-id)
$Env:YC_FOLDER_ID=$(yc config get folder-id)
```
Далее проверим конфигурацию **terraform** командой `terraform validate`, просмотрим план `terraform plan` и если всё в порядке применяем конфигурацию командой `terraform apply`
В результате выполнения должны получить в консоль вывод outputs содержащий ip-адреса создаваемых серверов: 
![Outputs.png](https://github.com/bulrza/fin/blob/main/img/Outputs.png)
В консоли управления Yandex Cloud проверяем созданные ресурсы:  
![Resourses.png](https://github.com/bulrza/fin/blob/main/img/Resourses.png)
Виртуальные машины для вэб серверов созданы в разных зонах:  
![vm-zones.png](https://github.com/bulrza/fin/blob/main/img/vm-zones.png)
Конфигурация облачной сети визульно отображена на карте:  
![vpc_map.png](https://github.com/bulrza/fin/blob/main/img/vpc_map.png)
Созданы Security Groups для серверов и балансировщика:
![sg_1.png](https://github.com/bulrza/fin/blob/main/img/sg_1.png)  
Сервера входящие в группу sg_internal выходят в интернет через NAT-шлюз (машина bastion-ansible)  
Проверим настройки резервного копирования:  
Расписание:  
![schedule_1.png](https://github.com/bulrza/fin/blob/main/img/schedule_1.png)
Снимки:  
![snapshots_1.png](https://github.com/bulrza/fin/blob/main/img/snapshots_1.png)
Проверим настройки балансировщика:  
![balancer_1.png](https://github.com/bulrza/fin/blob/main/img/balancer_1.png)
![target_1.png](https://github.com/bulrza/fin/blob/main/img/target_1.png)
![backend_1.png](https://github.com/bulrza/fin/blob/main/img/backend_1.png)
![router_1.png](https://github.com/bulrza/fin/blob/main/img/router_1.png)
![map_1.png](https://github.com/bulrza/fin/blob/main/img/map_1.png)
Поскольку специальных требований к сайту нет, установка **nginx** на сервера и изменение в страницу так же выполняются при помощи **terraform**  
Таким образом можно сразу проверить работу балансировщика.
Перейдем по публичному IP-адресу балансировщика и обновим страницу, по изменению имени вэб-сервера видна работа балансировщика:  
![site_1.png](https://github.com/bulrza/fin/blob/main/img/site_1.png)
![site_2.png](https://github.com/bulrza/fin/blob/main/img/site_2.png)
Дальнейшая настройка серверов будет выполняться с помощью **ansible**

### Настройка серверов с помощью Ansible
**Ansible** установлен на сервер bastion-ansible который имеет публичный IP-адрес и к нему открыт доступ по SSH.  
Для работы **Ansible** необходимо записать на него приватный ключ и задать на него необходимые права.
Для этого выполним следующие команды:
```
scp C:\Users\Bulushkin\.ssh\id_rsa ubuntu@89.169.171.215:/home/ubuntu/.ssh/id_rsa
ssh -i C:\Users\Bulushkin\.ssh\id_rsa ubuntu@89.169.171.215 chmod 600 /home/ubuntu/.ssh/id_rsa
```
Где IP-адрес будет публичный (NAT) адрес машины bastion-ansible полученный в outputs
Далее надо записать на сервер конфигурационные файлы ansible, для чего можно использовать **git** (он уже установлен на сервер).  
Поскольку у меня есть локальная копия репозитория git, я просто скопирую папку командой `scp -r 'C:\Users\Bulushkin\Documents\terraform test\diploma-fin\ansible' ubuntu@89.169.171.215:/home/ubuntu/`
После этого соединяемся по ssh с данным сервером: `ssh -i C:\Users\Bulushkin\.ssh\id_rsa ubuntu@89.169.171.215`
Перейдём в папку ansible и протестируем доступность хостов с помощью команды `ansible all -m ping`
![ansible_ping.png](https://github.com/bulrza/fin/blob/main/img/ansible_ping.png)
Далее поочередно выполняем плэйбуки:  
Для настройки сервера **Zabbix** `ansible-playbook zabbix.yml`
![zabbix_1.png](https://github.com/bulrza/fin/blob/main/img/zabbix_1.png)
Для установки **zabbix-agent** на все сервера `ansible-playbook zabbix_agent.yml`
![zabbix_agent_1.png](https://github.com/bulrza/fin/blob/main/img/zabbix_agent_1.png)
Для настройки сервера **elasticsearch** `ansible-playbook elastic.yml`
![elastic_1.png](https://github.com/bulrza/fin/blob/main/img/elastic_1.png)
Для настройки сервера **kibana** `ansible-playbook kibana.yml`
![kibana_1.png](https://github.com/bulrza/fin/blob/main/img/kibana_1.png)
Для установки **filebeat** на вэб-сервера `ansible-playbook filebeat.yml`
![filebeat_1.png](https://github.com/bulrza/fin/blob/main/img/filebeat_1.png)
Дальнейшая настройка будет осуществляться через вэб интерфейсы сервера Zabbix и Kibana
Ссылка на вэб интерфейс Zabbix:
[Zabbix](http://89.169.175.236/zabbix)
Логин: Admin Пароль: zabbix
Ссылка на вэб интерфейс Kibana:
[Kibana](http://89.169.161.36:5601/)
