#!/bin/bash
# Script de setup inicial para servidor de deployment
# Ejecutar en el servidor como usuario 'deploy'

set -e  # Salir si hay errores

echo "=========================================="
echo " Setup de Servidor para Deployment"
echo " Warband Campaign Manager"
echo "=========================================="
echo ""

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Instalando dependencias del sistema ===${NC}"
sudo apt update
sudo apt install -y nginx nodejs npm build-essential libsqlite3-dev curl git

echo -e "${GREEN}✓ Dependencias del sistema instaladas${NC}"
echo ""

echo -e "${YELLOW}=== Instalando rbenv ===${NC}"
if [ ! -d "$HOME/.rbenv" ]; then
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

  # Añadir a bashrc si no está ya
  if ! grep -q "rbenv init" ~/.bashrc; then
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
  fi

  echo -e "${GREEN}✓ rbenv instalado${NC}"
else
  echo -e "${GREEN}✓ rbenv ya está instalado${NC}"
fi
echo ""

# Cargar rbenv en la sesión actual
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

echo -e "${YELLOW}=== Instalando Ruby 3.1.2 ===${NC}"
if ! rbenv versions | grep -q "3.1.2"; then
  rbenv install 3.1.2
  echo -e "${GREEN}✓ Ruby 3.1.2 instalado${NC}"
else
  echo -e "${GREEN}✓ Ruby 3.1.2 ya está instalado${NC}"
fi

rbenv global 3.1.2
rbenv rehash

echo -e "${GREEN}✓ Ruby version:${NC} $(ruby -v)"
echo ""

echo -e "${YELLOW}=== Instalando Bundler ===${NC}"
gem install bundler
rbenv rehash
echo -e "${GREEN}✓ Bundler instalado${NC}"
echo ""

echo -e "${YELLOW}=== Creando estructura de directorios de deployment ===${NC}"
mkdir -p ~/warband_campaign_manager/shared/config
mkdir -p ~/warband_campaign_manager/shared/log
mkdir -p ~/warband_campaign_manager/shared/tmp/pids
mkdir -p ~/warband_campaign_manager/shared/tmp/cache
mkdir -p ~/warband_campaign_manager/shared/tmp/sockets
mkdir -p ~/warband_campaign_manager/shared/storage
mkdir -p ~/backups

echo -e "${GREEN}✓ Directorios creados${NC}"
echo ""

echo -e "${GREEN}=========================================="
echo " Setup Completado!"
echo "==========================================${NC}"
echo ""
echo -e "${YELLOW}Próximos pasos:${NC}"
echo ""
echo "1. Subir master.key al servidor:"
echo "   ${GREEN}scp config/master.key deploy@164.90.207.74:~/warband_campaign_manager/shared/config/${NC}"
echo ""
echo "2. Crear servicio systemd de Puma:"
echo "   Ver instrucciones en DEPLOYMENT_CHECKLIST.md"
echo "   Archivo: /etc/systemd/system/puma_warband_campaign_manager.service"
echo ""
echo "3. Configurar nginx:"
echo "   Ver instrucciones en DEPLOYMENT_CHECKLIST.md"
echo "   Archivo: /etc/nginx/sites-available/warband_campaign_manager"
echo ""
echo "4. Generar certificado SSL (auto-firmado para pruebas):"
echo "   ${GREEN}sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \\${NC}"
echo "   ${GREEN}  -keyout /etc/ssl/private/nginx-selfsigned.key \\${NC}"
echo "   ${GREEN}  -out /etc/ssl/certs/nginx-selfsigned.crt${NC}"
echo ""
echo "5. Verificar configuración de Capistrano (desde máquina local):"
echo "   ${GREEN}bundle exec cap production deploy:check${NC}"
echo ""
echo "6. Hacer el primer deployment (desde máquina local):"
echo "   ${GREEN}bundle exec cap production deploy${NC}"
echo ""
echo -e "${YELLOW}Nota:${NC} Recuerda que debes reiniciar tu terminal o ejecutar:"
echo "  ${GREEN}source ~/.bashrc${NC}"
echo "para que rbenv esté disponible en tu PATH."
echo ""
