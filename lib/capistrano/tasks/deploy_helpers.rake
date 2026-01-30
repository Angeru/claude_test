namespace :deploy do
  desc 'Verify deployment health'
  task :health_check do
    on roles(:app) do
      within release_path do
        info "Checking application health..."
        execute :curl, '-f', '-k', 'https://localhost/', '||', 'echo', '"WARNING: Health check failed"'
      end
    end
  end

  desc 'Show deployment info'
  task :info do
    on roles(:app) do
      within release_path do
        info "Deployment directory: #{release_path}"
        begin
          revision = capture(:cat, 'REVISION')
          info "Git revision: #{revision}"
        rescue
          info "No REVISION file found"
        end
        info "Puma status:"
        begin
          execute 'sudo', 'systemctl', 'status', 'puma_warband_campaign_manager', '--no-pager'
        rescue
          info "Puma service not running or not found"
        end
      end
    end
  end

  desc 'Tail production logs'
  task :logs do
    on roles(:app) do
      execute :tail, '-f', '-n', '50', "#{shared_path}/log/production.log"
    end
  end

  namespace :db do
    desc 'Backup SQLite database'
    task :backup do
      on roles(:db) do
        within shared_path do
          timestamp = Time.now.strftime("%Y%m%d%H%M%S")
          backup_file = "storage/production.sqlite3.backup.#{timestamp}"
          if test("[ -f storage/production.sqlite3 ]")
            execute :cp, 'storage/production.sqlite3', backup_file
            info "Database backed up to #{backup_file}"
          else
            warn "Database file not found, skipping backup"
          end
        end
      end
    end

    desc 'Download database backup to local machine'
    task :download_backup do
      on roles(:db) do
        within shared_path do
          timestamp = Time.now.strftime("%Y%m%d%H%M%S")
          remote_file = "storage/production.sqlite3"
          local_file = "backups/production_#{timestamp}.sqlite3"

          run_locally do
            execute :mkdir, '-p', 'backups'
          end

          if test("[ -f #{remote_file} ]")
            download! remote_file, local_file
            info "Database downloaded to #{local_file}"
          else
            error "Remote database file not found at #{remote_file}"
          end
        end
      end
    end
  end
end

# Auto-backup database before migrations
before 'deploy:migrate', 'deploy:db:backup'

# Health check after deployment
after 'deploy:publishing', 'deploy:health_check'
