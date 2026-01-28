# CLAUDE.md

Este archivo proporciona orientación a Claude Code (claude.ai/code) para trabajar con el código de este repositorio.

## Descripción del Proyecto

Aplicación Rails 7.1 con autenticación basada en sesiones. Usa Hotwire (Turbo + Stimulus), Tailwind CSS y SQLite.

## Comandos

```bash
# Servidor de desarrollo (ejecuta Rails + watcher de Tailwind)
bin/dev

# Ejecutar todos los tests
bin/rails test

# Ejecutar un archivo de test específico
bin/rails test test/models/user_test.rb

# Ejecutar un test específico por número de línea
bin/rails test test/models/user_test.rb:10

# Operaciones de base de datos
bin/rails db:migrate
bin/rails db:reset        # drop, create, migrate, seed

# Consola de Rails
bin/rails console
```

## Arquitectura

### Sistema de Autenticación

Autenticación basada en sesiones implementada sin Devise:
- `ApplicationController` provee los helpers `current_user`, `logged_in?` y `require_login`
- `SessionsController` maneja login/logout mediante `session[:user_id]`
- El modelo `User` usa `has_secure_password` (bcrypt) para hashear contraseñas
- Flujo de reset de contraseña: `PasswordResetsController` + `UserMailer#password_reset` con tokens temporales (2 horas)

### Rutas Principales

- `/signup` → registro de usuarios
- `/login` / `/logout` → manejo de sesiones
- `/password_resets` → flujo de recuperación de contraseña
- `/dashboard` → área autenticada (requiere login)

## Notas de Desarrollo

- Previsualizaciones de email disponibles en desarrollo via gema `letter_opener`
- Tailwind CSS compilado via gema `tailwindcss-rails` (config en `config/tailwind.config.js`)
