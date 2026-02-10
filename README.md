# Warband Campaign Manager

Aplicación Rails para gestionar campañas del juego Mordheim.

## Producción

🚀 Desplegado en Digital Ocean: http://142.93.228.193

## Desarrollo Local

```bash
# Instalar dependencias
bundle install

# Configurar base de datos
bin/rails db:setup

# Iniciar servidor de desarrollo
bin/dev
```

## Despliegue

```bash
# Desplegar cambios a producción
kamal deploy

# Ver logs
kamal app logs --follow

# Estado del despliegue
kamal details
```

## Stack Tecnológico

- Ruby 3.1.2
- Rails 7.1.6
- SQLite (producción y desarrollo)
- Hotwire (Turbo + Stimulus)
- Tailwind CSS
- Kamal (despliegue)
- Digital Ocean (hosting)
