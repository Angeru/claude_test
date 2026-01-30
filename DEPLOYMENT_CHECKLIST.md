# Deployment Checklist

## Antes del Primer Deployment

### Máquina Local
- [ ] Acceso SSH al servidor funciona: `ssh deploy@164.90.207.74`
- [ ] Repositorio git es accesible
- [ ] `config/master.key` existe localmente
- [ ] Todas las gemas instaladas: `bundle install`
- [ ] Tests pasando: `bin/rails test`

### Servidor (164.90.207.74)
- [ ] Paquetes del sistema instalados (nginx, nodejs, build-essential, libsqlite3-dev)
- [ ] rbenv instalado y Ruby 3.1.2 configurado
- [ ] Usuario 'deploy' existe con permisos adecuados
- [ ] Directorios de deployment creados en `/home/deploy/warband_campaign_manager`
- [ ] `master.key` subido a `shared/config/`
- [ ] Servicio systemd de Puma creado y habilitado
- [ ] Nginx configurado y corriendo
- [ ] Certificado SSL configurado (aunque sea auto-firmado para pruebas)
- [ ] Firewall permite puertos 22, 80, 443

### Aplicación
- [ ] Todos los commits pusheados a GitHub (rama main)
- [ ] Migraciones de BD actualizadas localmente
- [ ] Tests pasando: `bin/rails test`

## Setup Inicial del Servidor

### 1. Ejecutar Script de Setup

```bash
# Copiar script al servidor
scp bin/setup_server.sh deploy@164.90.207.74:~

# Ejecutar en el servidor
ssh deploy@164.90.207.74 'bash setup_server.sh'
```

### 2. Subir Master Key

```bash
scp config/master.key deploy@164.90.207.74:/home/deploy/warband_campaign_manager/shared/config/
```

### 3. Crear Servicio Systemd de Puma

En el servidor, crear `/etc/systemd/system/puma_warband_campaign_manager.service`:

```ini
[Unit]
Description=Puma HTTP Server for warband_campaign_manager
After=network.target

[Service]
Type=notify
User=deploy
WorkingDirectory=/home/deploy/warband_campaign_manager/current
Environment=RAILS_ENV=production
Environment=RBENV_ROOT=/home/deploy/.rbenv
Environment=RBENV_VERSION=3.1.2
ExecStart=/home/deploy/.rbenv/shims/bundle exec puma -C /home/deploy/warband_campaign_manager/current/config/puma.rb
ExecReload=/bin/kill -USR1 $MAINPID
StandardOutput=append:/home/deploy/warband_campaign_manager/shared/log/puma.access.log
StandardError=append:/home/deploy/warband_campaign_manager/shared/log/puma.error.log
Restart=always
RestartSec=10
SyslogIdentifier=puma_warband_campaign_manager

[Install]
WantedBy=multi-user.target
```

Habilitar el servicio:

```bash
sudo systemctl daemon-reload
sudo systemctl enable puma_warband_campaign_manager
```

### 4. Configurar Nginx

Crear `/etc/nginx/sites-available/warband_campaign_manager`:

```nginx
upstream puma_warband_campaign_manager {
  server unix:///home/deploy/warband_campaign_manager/shared/tmp/sockets/puma.sock;
}

server {
  listen 80;
  server_name 164.90.207.74;  # Cambiar por dominio si está disponible

  # Redirigir a HTTPS
  return 301 https://$server_name$request_uri;
}

server {
  listen 443 ssl http2;
  server_name 164.90.207.74;  # Cambiar por dominio si está disponible

  # Configuración SSL (usar Let's Encrypt certbot para certificados reales)
  # Para pruebas, generar certificado auto-firmado:
  # sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  #   -keyout /etc/ssl/private/nginx-selfsigned.key \
  #   -out /etc/ssl/certs/nginx-selfsigned.crt
  ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
  ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

  root /home/deploy/warband_campaign_manager/current/public;

  try_files $uri/index.html $uri @puma;

  location @puma {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://puma_warband_campaign_manager;
  }

  location ^~ /assets/ {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
  }

  error_page 500 502 503 504 /500.html;
  client_max_body_size 10M;
  keepalive_timeout 10;
}
```

Habilitar el sitio:

```bash
sudo ln -s /etc/nginx/sites-available/warband_campaign_manager /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 5. Generar Certificado SSL

#### Opción A: Auto-firmado (para pruebas)

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/nginx-selfsigned.key \
  -out /etc/ssl/certs/nginx-selfsigned.crt
```

#### Opción B: Let's Encrypt (para producción)

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d tudominio.com
```

## Comandos de Primer Deployment

```bash
# 1. Verificar configuración de deployment
bundle exec cap production deploy:check

# 2. Desplegar la aplicación
bundle exec cap production deploy

# 3. SSH al servidor y verificar
ssh deploy@164.90.207.74
sudo systemctl status puma_warband_campaign_manager
curl -k https://localhost
```

## Deployment Regular

```bash
# Deployment estándar
bundle exec cap production deploy

# Ver logs
bundle exec cap production deploy:logs

# Verificar estado del deployment
bundle exec cap production deploy:info

# Backup y descarga de base de datos
bundle exec cap production deploy:db:download_backup
```

## Rollback

```bash
bundle exec cap production deploy:rollback
```

## Troubleshooting

### Puma no arranca

```bash
ssh deploy@164.90.207.74
cd /home/deploy/warband_campaign_manager/current
sudo systemctl status puma_warband_campaign_manager
sudo journalctl -u puma_warband_campaign_manager -n 50
```

**Causas comunes:**
- `master.key` no está en `shared/config/`
- Permisos incorrectos en directorios
- Ruby no instalado correctamente con rbenv
- Error en bundle install

### Assets no cargan

```bash
# Verificar si los assets están precompilados
ls -la /home/deploy/warband_campaign_manager/current/public/assets/

# Precompilar manualmente si es necesario
cd /home/deploy/warband_campaign_manager/current
RAILS_ENV=production bundle exec rails assets:precompile
```

### Problemas de base de datos

```bash
# Verificar que la base de datos existe
ls -la /home/deploy/warband_campaign_manager/shared/storage/

# Ejecutar migraciones manualmente
cd /home/deploy/warband_campaign_manager/current
RAILS_ENV=production bundle exec rails db:migrate
```

### Error 502 Bad Gateway

**Causa:** Nginx no puede conectar con Puma.

**Solución:**
```bash
# Verificar que Puma está corriendo
sudo systemctl status puma_warband_campaign_manager

# Verificar que el socket existe
ls -la /home/deploy/warband_campaign_manager/shared/tmp/sockets/puma.sock

# Reiniciar Puma
sudo systemctl restart puma_warband_campaign_manager
```

### Permisos denegados

```bash
# Verificar permisos del directorio de deployment
ls -la /home/deploy/

# El directorio debe pertenecer al usuario deploy
sudo chown -R deploy:deploy /home/deploy/warband_campaign_manager
```

### Problemas con SSH/Git

```bash
# Verificar que el forward agent funciona
ssh -A deploy@164.90.207.74
ssh -T git@github.com

# Debe mostrar: "Hi username! You've successfully authenticated..."
```

### Error: Could not find master.key

```bash
# Verificar que master.key está en el lugar correcto
ssh deploy@164.90.207.74 'ls -la /home/deploy/warband_campaign_manager/shared/config/master.key'

# Si no existe, subirlo nuevamente
scp config/master.key deploy@164.90.207.74:/home/deploy/warband_campaign_manager/shared/config/
```

### Logs útiles

```bash
# Logs de Puma
tail -f /home/deploy/warband_campaign_manager/shared/log/puma.error.log

# Logs de Rails
tail -f /home/deploy/warband_campaign_manager/shared/log/production.log

# Logs de Nginx
sudo tail -f /var/log/nginx/error.log

# Logs de systemd
sudo journalctl -u puma_warband_campaign_manager -f
```

## Backups de Base de Datos

### Backup Automático

Los backups se crean automáticamente antes de cada migración gracias al hook en `deploy_helpers.rake`.

### Backup Manual

```bash
# Crear backup en el servidor
bundle exec cap production deploy:db:backup

# Descargar backup a máquina local
bundle exec cap production deploy:db:download_backup
```

### Backup Programado (opcional)

Añadir al crontab del usuario deploy en el servidor:

```bash
# Editar crontab
crontab -e

# Añadir línea para backup diario a las 2 AM
0 2 * * * cp /home/deploy/warband_campaign_manager/shared/storage/production.sqlite3 \
  /home/deploy/backups/production_$(date +\%Y\%m\%d).sqlite3
```

### Restaurar desde Backup

```bash
# En el servidor
ssh deploy@164.90.207.74
cd /home/deploy/warband_campaign_manager/shared/storage
cp production.sqlite3.backup.YYYYMMDDHHMMSS production.sqlite3
sudo systemctl restart puma_warband_campaign_manager
```

## Monitoreo Post-Deployment

### Verificaciones Inmediatas

```bash
# 1. Estado del servicio
ssh deploy@164.90.207.74 'sudo systemctl status puma_warband_campaign_manager'

# 2. Respuesta HTTP
curl -k https://164.90.207.74

# 3. Logs recientes
bundle exec cap production deploy:logs

# 4. Base de datos
ssh deploy@164.90.207.74 'ls -lh /home/deploy/warband_campaign_manager/shared/storage/production.sqlite3'
```

### Prueba de Flujo Completo

1. Abrir navegador en `https://164.90.207.74`
2. Registrar un usuario nuevo
3. Crear una campaña
4. Crear una warband
5. Verificar que los datos persisten después de refrescar la página

### Test de Rollback

```bash
# Después del primer deployment exitoso
bundle exec cap production deploy:rollback
curl -k https://164.90.207.74  # Debe seguir funcionando
```

## Mantenimiento

### Actualizar Aplicación

```bash
# 1. Hacer cambios localmente
# 2. Ejecutar tests
bin/rails test

# 3. Commit y push
git add .
git commit -m "Descripción de cambios"
git push origin main

# 4. Deploy
bundle exec cap production deploy
```

### Limpiar Releases Antiguas

Capistrano mantiene automáticamente solo las últimas 5 releases (configurado en `deploy.rb`).

Para limpiar manualmente:

```bash
bundle exec cap production deploy:cleanup
```

### Espacio en Disco

```bash
# Verificar espacio disponible
ssh deploy@164.90.207.74 'df -h'

# Verificar tamaño de la base de datos
ssh deploy@164.90.207.74 'du -h /home/deploy/warband_campaign_manager/shared/storage/production.sqlite3'

# Limpiar logs antiguos si es necesario
ssh deploy@164.90.207.74 'sudo journalctl --vacuum-time=7d'
```

## Comandos Rápidos de Referencia

```bash
# Deploy
bundle exec cap production deploy

# Rollback
bundle exec cap production deploy:rollback

# Ver logs
bundle exec cap production deploy:logs

# Info del deployment
bundle exec cap production deploy:info

# Backup DB
bundle exec cap production deploy:db:backup

# Descargar DB
bundle exec cap production deploy:db:download_backup

# Verificar configuración
bundle exec cap production deploy:check

# SSH al servidor
ssh deploy@164.90.207.74

# Reiniciar Puma
ssh deploy@164.90.207.74 'sudo systemctl restart puma_warband_campaign_manager'

# Ver estado Puma
ssh deploy@164.90.207.74 'sudo systemctl status puma_warband_campaign_manager'
```
