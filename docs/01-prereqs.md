# 01-prereqs — подготовка окружения

Этот документ описывает, что нужно подготовить до установки: VM, сеть, DNS, порты и базовые пакеты на Debian.

## 1) Исходные вводные (принято в проекте)

- У нас 2 VM:
  - **VM1**: `gitea` — контейнеры Gitea + PostgreSQL (через Docker Compose).
  - **VM2**: `runner` — act_runner + Docker для сборки Docker-образов (CI).
- Доступ: только из корпоративной сети, по DNS-имени (пример `git.intra.local`).
- На первом этапе веб доступ допускается без reverse proxy: `http://git.intra.local:3000`.
- SSH для git будет опубликован отдельным портом (пример `2222 -> 22`), чтобы не конфликтовать с SSH самой VM.

## 2) Требования к VM (минимум)

### VM1 (Gitea + Postgres + Nginx)
- CPU: 2 vCPU (минимум), лучше 4 vCPU
- RAM: 4–8 GB
- Disk: SSD, начать от 30–50 GB + запас под репозитории/вложения
- ОС: Debian 11/12
- ПО: Docker Engine + Docker Compose plugin

### VM2 (Runner)
- CPU: 4–8 vCPU (под 2 параллельные сборки)
- RAM: 8–16 GB
- Disk: SSD, начать от 50 GB
- ОС: Debian 11/12
- ПО: Docker Engine (обязательно)

## 3) Сеть и DNS

### DNS
- Создайте DNS A/AAAA запись: `git.<ваш_домен>` → IP VM1.
- Убедитесь, что с рабочих ПК в сети имя резолвится и пингуется.

### Порты и доступность
Откройте доступ (на фаерволе/ACL/гипервизоре) **только из вашей сети**:

- VM1:
  - `3000/tcp` — web интерфейс Gitea (если без прокси)
  - `2222/tcp` — SSH Git (проброс на контейнерный `22/tcp`)
- VM2:
  - входящие порты обычно не нужны (если только вы не планируете администрировать runner особым образом)
  - важнее исходящий доступ **VM2 → VM1:3000** (runner должен достучаться до Gitea)

## 4) Требования к БД

Мы используем PostgreSQL. Gitea официально поддерживает PostgreSQL версии **>= 12**. (В этом проекте PostgreSQL запускается как контейнер.)  
Источник: документация Gitea “Database Preparation”.  
https://docs.gitea.com/installation/database-prep

## 5) Установка Docker на Debian (VM1 и VM2)

### Рекомендуемый способ
Устанавливайте Docker из официального репозитория Docker для Debian.  
Источник: Docker Docs “Install Docker Engine on Debian”.  
https://docs.docker.com/engine/install/debian/

### Compose plugin
Docker Compose v2 ставится как плагин `docker-compose-plugin` (проверка: `docker compose version`).  
Источник: Docker Docs “Install the Docker Compose plugin”.  
https://docs.docker.com/compose/install/linux/
