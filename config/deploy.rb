# config valid for current version and patch releases of Capistrano
lock "~> 3.20.0"

# Nombre de la aplicación
set :application, "warband_campaign_manager"
set :repo_url, "git@github.com:Angeru/claude_test.git"

# Rama a deployar
set :branch, "main"

# Usuario del servidor
set :user, "deploy"

# Directorio de deployment
set :deploy_to, "/home/deploy/#{fetch(:application)}"

# Rbenv settings
set :rbenv_type, :user
set :rbenv_ruby, File.read('.ruby-version').strip  # Lee 3.1.2 desde .ruby-version

# Archivos/directorios persistentes entre deploys
append :linked_files, "config/master.key"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "storage"

# Configuración de Puma
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{shared_path}/log/puma.access.log"
set :puma_error_log, "#{shared_path}/log/puma.error.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true
set :puma_enable_socket_service, true

# Número de releases a mantener
set :keep_releases, 5

# Log level para debugging
set :log_level, :info

# Opciones SSH
set :ssh_options, {
  forward_agent: true,
  auth_methods: %w(publickey),
  keys: %w(~/.ssh/id_ed25519)
}

# Variables de entorno por defecto
set :default_env, {
  'RAILS_ENV' => 'production',
  'NODE_ENV' => 'production'
}

# Hooks de Puma
after 'deploy:publishing', 'puma:restart'
after 'deploy:finishing', 'puma:start'

# Tareas antes de restart
namespace :deploy do
  desc 'Precompile Tailwind CSS'
  task :precompile_tailwind do
    on roles(:app) do
      within release_path do
        execute :bundle, :exec, :rails, 'tailwindcss:build'
      end
    end
  end

  before 'deploy:assets:precompile', 'deploy:precompile_tailwind'
end
