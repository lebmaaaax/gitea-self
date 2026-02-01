# 00-overview — обзор проекта

Этот репозиторий — учебный проект по развертыванию собственного Git-сервера на базе Gitea в локальной сети компании. Цель — получить воспроизводимую установку на “чистых” VM: Gitea в контейнере, PostgreSQL как база данных, отдельная VM для CI (Gitea Actions runner) под сборку Docker-образов внутренних сервисов.

## Цели и границы
- Поднять Gitea так, чтобы разработчики могли: создавать репозитории, работать по HTTP(S) и по SSH, управлять доступами.
- Поднять CI для 2 параллельных сборок Docker-образов (через act_runner).
- Проект ориентирован на внутреннюю сеть (доступ по DNS-имени), без экспонирования в интернет.

## Архитектура (2 VM)

### VM1: gitea + postgres
Назначение: Git-сервер и данные (репозитории, users, issues, packages при необходимости).

Состав:
- Gitea (Docker container)
- PostgreSQL (Docker container)
- Docker volumes для постоянного хранения данных

Порты:
- Web: `3000/tcp` (на старте без reverse proxy)
- SSH Git: `2222/tcp` → внутрь контейнера на `22/tcp` (чтобы не конфликтовать с SSH самой VM)

Доступ:
- Пользователи ходят по DNS-имени (пример): `http://git.intra.local:3000`
- SSH clone/push (пример): `ssh://git@git.intra.local:2222/<owner>/<repo>.git`

### VM2: actions runner
Назначение: выполнение CI jobs (сборка образов, тесты, линтеры).

Состав:
- Docker Engine (обязательно для сборки Docker-образов)
- act_runner (один или несколько инстансов)

Параллелизм:
- Для 2 одновременных сборок запускаем 2 runner-инстанса (два процесса/сервиса или два контейнера).

## Потоки данных и ответственность
- Gitea хранит “состояние”: репозитории, настройки, users, задачи — на VM1 в Docker volume.
- PostgreSQL хранит метаданные Gitea — также на VM1 в отдельном Docker volume.
- Runner не хранит критичные данные, но использует локальный Docker cache (слои/кэш сборок), который может занимать много места на диске VM2.

## DNS и URL-каноничность
Важный принцип: внешний адрес, который видят пользователи (DNS-имя и схема http/https), должен быть стабилен. Он используется:
- в ссылках и редиректах веб-интерфейса,
- в URL клонирования,
- в вебхуках и интеграциях (если добавите позже).

На первом этапе допускается `http://<dns>:3000`, позже можно перейти на `https://<dns>/` через reverse proxy.

## Безопасность (минимально необходимое)
- Gitea доступна только из корпоративной сети/VPN (сетевые ACL/фаервол).
- Секреты (пароли БД, токены runner’ов) не хранятся в репозитории; только `.env.example` и шаблоны конфигов.
- Runner следует считать менее доверенным узлом (он исполняет код из репозиториев и работает с Docker).

## Эксплуатационные договоренности
- Бэкапы: отдельно данные Gitea (volume), отдельно дампы PostgreSQL.
- Обновления: фиксировать версии образов и обновлять контролируемо.
- Логи: смотреть через `docker compose logs` на VM1 и логи runner’ов на VM2.

gitea-selfhosted-lab/
├── README.md                          
├── LICENSE
├── .gitignore
│
├── vm1-gitea/                          # Всё для VM1 (Gitea+Postgres+Nginx)
│   ├── docker-compose.yml
│   ├── .env.example
│   ├── nginx/
│   │   ├── gitea.conf
│   │   └── certs/.gitkeep
│   └── README.md                       # Краткая инструкция для VM1
│
├── vm2-runner/                         # Всё для VM2 (act_runner)
│   ├── docker-compose.yml              # Runner в контейнере
│   ├── .env.example
│   ├── config.yaml.example             # Конфиг runner (если нужен)
│   ├── systemd/
│   │   └── act_runner.service          # Альтернатива: systemd unit
│   └── README.md                       # Краткая инструкция для VM2
│
├── scripts/
│   ├── docker-vm1.sh                    # Автоматическая установка Docker на VM1
│   ├── backup-gitea.sh
│   ├── restore-gitea.sh
│   └── healthcheck.sh
│
├── workflows-examples/                 # Примеры Gitea Actions workflows
│   ├── build-and-push.yml
│   ├── deploy-to-vm3.yml
│   └── test-ci.yml
│
├── docs/
│   ├── 00-overview.md
│   ├── 01-quick-start.md               # Быстрый старт (5 минут)
│   ├── 02-detailed-install.md          # Подробная установка
│   ├── 03-https-setup.md
│   ├── 04-ci-cd-setup.md
│   └── 05-troubleshooting.md
