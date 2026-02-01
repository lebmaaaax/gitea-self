### Требования
- 2 VM с Debian 11/12
- DNS-запись для Gitea (например `git.company.local`)
- Доступ из вашей сети

### 1: Клонировать репозиторий

На вашем рабочем ПК:
```bash
git clone https://github.com/lebmaaaax/gitea-self.git
```
### 2: Подготовить VM1 (Gitea)

Скопируйте каталог vm1-gitea/ на VM1:
```bash
scp -r vm1-gitea/ user@vm1-ip:/tmp/
```
На VM1 выполните:
```bash
cd /tmp/vm1-gitea
chmod +x ../scripts/setup-vm1.sh
sudo ../scripts/setup-vm1.sh  
```
Создайте .env из шаблона:
```bash
cp .env.example .env
nano .env  # Заполните DNS, пароли
```
Запустите:
```bash
sudo docker compose up -d
```
Откройте браузер: http://git.company.local/

3: Подготовить VM2 (Runner)
Скопируйте каталог vm2-runner/ на VM2:
```bash
scp -r vm2-runner/ user@vm2-ip:/tmp/
```

На VM2:
```bash
cd /tmp/vm2-runner
chmod +x ../scripts/setup-vm2.sh
sudo ../scripts/setup-vm2.sh 
```
### Получите токен регистрации в Gitea UI:
## Admin Area → Actions → Runners → Generate Token
Заполните .env:
```bash
cp .env.example .env
nano .env  # Вставьте токен
```
Запустите:
```bash
sudo docker compose up -d
```
Готово! Проверьте в Gitea UI → Actions → Runners
