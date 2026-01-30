# IP de tu droplet - CAMBIAR ESTO POR LA IP REAL DE TU SERVIDOR
server "164.90.207.74",
  user: "deploy",
  roles: %w{app db web},
  ssh_options: {
    forward_agent: true,
    auth_methods: %w(publickey),
    keys: %w(~/.ssh/id_ed25519)  # O tu clave SSH específica
  }

# Configuración de Rails
set :rails_env, "production"
set :puma_env, fetch(:rails_env)
