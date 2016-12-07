namespace :load do
  task :defaults do
    set :postgres_backup_dir, -> { 'postgres_backup' }
    set :postgres_locale_backup_dir, -> { 'postgres_locale_backup' }
    
    set :postgres_role, :db
    set :postgres_env, -> { fetch(:rack_env, fetch(:rails_env, fetch(:stage))) }
    
    set :postgres_remote_sql_file_path, -> { nil }
    set :postgres_remote_locale_sql_file_path, -> { nil }
    
    set :postgres_remote_username, ask('Remote Postgres Username:', 'postgres')
    set :postgres_remote_password, ask('Remote Postgres Password:', 'password', echo: false)
    set :postgres_remote_database_staging, ask('Remote Postgres Database:', 'fusseo_staging')
    set :postgres_remote_database_live, ask('Remote Postgres Database:', 'fusseo_live')
    set :postgres_remote_database_test, ask('Remote Postgres Test Database:', 'fusseo_test')
    set :postgres_remote_host, ask('Remote Postgres Host:', 'localhost')
    set :postgres_remote_system_user, ask('Remote Postgres System User:', 'postgres')
    set :postgres_remote_system_db, ask('Remote Postgres System Database:', 'postgres')
  end
end

namespace :postgres do
  
  desc 'Create database'
  task :create_database do
    on roles(fetch(:postgres_role)) do |role|
      begin
        execute "PGPASSWORD=#{fetch(:postgres_remote_password)} " \
                "createdb #{fetch(:postgres_remote_database_staging)} "\
                "-U #{fetch(:postgres_remote_username)}"
        execute "PGPASSWORD=#{fetch(:postgres_remote_password)} " \
                "createdb #{fetch(:postgres_remote_database_test)} "\
                "-U #{fetch(:postgres_remote_username)}"
      rescue => e
        warn e.message
      end
    end
  end
  
  desc 'Drop database'
  task :drop_database do
    on roles(fetch(:postgres_role)) do |role|
      begin
        execute "PGPASSWORD=#{fetch(:postgres_remote_password)} " \
                "dropdb #{fetch(:postgres_remote_database_staging)} "\
                "-U #{fetch(:postgres_remote_username)}"
        execute "PGPASSWORD=#{fetch(:postgres_remote_password)} " \
                "dropdb #{fetch(:postgres_remote_database_test)} "\
                "-U #{fetch(:postgres_remote_username)}"
      rescue => e
        warn e.message
      end
    end
  end
  
  desc 'Create database dump'
  task :backup do
    on roles(fetch(:postgres_role)) do |role|
      postgres_remote_username = fetch(:postgres_remote_username)
      postgres_remote_password = fetch(:postgres_remote_password)
      postgres_remote_database = fetch(:postgres_remote_database_staging)
      
      postgres_remote_host = fetch(:postgres_remote_host)
      time                 = Time.now.strftime('%Y-%m-%d_%H-%M-%S')
      
      begin
        unless fetch(:postgres_remote_sql_file_path)
          file_name = "full_backup.#{time}.sql"
          set :postgres_remote_sql_file_path, "#{shared_path}/#{fetch(:postgres_backup_dir)}/#{file_name}"
        end

        
        dump_query = " pg_dump -U #{postgres_remote_username} " \
                     " -h #{postgres_remote_host} "\
                     " #{postgres_remote_database} " \
                     " -c > #{fetch(:postgres_remote_sql_file_path)} "
        
        execute dump_query
      rescue => e
        warn e.message
      end
    end
  end

# Ensure that remote dirs for postgres backup exist
  before :backup, :ensure_remote_dirs do
    on roles(fetch(:postgres_role)) do |role|
      execute :mkdir, "-p #{shared_path}/#{fetch(:postgres_backup_dir)}"
      execute :mkdir, "-p #{shared_path}/#{fetch(:postgres_locale_backup_dir)}"
    end
  end
  
  desc 'Download last database dump'
  task :download do
    on roles(fetch(:postgres_role)) do |role|
      unless fetch(:postgres_remote_locale_sql_file_path)
        file_name = capture("ls -v #{shared_path}/#{fetch :postgres_locale_backup_dir}").split(" ").last
        set :postgres_remote_locale_sql_file_path, "#{shared_path}/#{fetch :postgres_locale_backup_dir}/#{file_name}"
      end
      
      download!(fetch(:postgres_remote_locale_sql_file_path), "tmp/#{fetch :postgres_locale_backup_dir}/#{Pathname.new(fetch(:postgres_remote_locale_sql_file_path)).basename}")
      
      unless fetch(:postgres_remote_sql_file_path)
        file_name = capture("ls -v #{shared_path}/#{fetch :postgres_backup_dir}").split(" ").last
        set :postgres_remote_sql_file_path, "#{shared_path}/#{fetch :postgres_backup_dir}/#{file_name}"
      end
      
      download!(fetch(:postgres_remote_sql_file_path), "tmp/#{fetch :postgres_backup_dir}/#{Pathname.new(fetch(:postgres_remote_sql_file_path)).basename}")
    end
  end
  
  desc "Import last full dump"
  task :import do
    run_locally do
      unless fetch(:database_name)
        ask(:database_name, 'fusseo_dev')
      end
      
      with rails_env: :development do
        file_name = capture("ls -v tmp/#{fetch :postgres_backup_dir}").split(" ").last
        file_path = "tmp/#{fetch :postgres_backup_dir}/#{file_name}"
        
        restore_dump = "psql -U postgres #{fetch(:database_name)}< #{file_path}"
        execute restore_dump
      end
    end
  end
  
  desc "Import last locale dump"
  task :import_locale do
    run_locally do
      unless fetch(:database_name)
        ask(:database_name, 'fusseo_dev')
      end
      
      with rails_env: :development do
        file_name = capture("ls -v tmp/#{fetch :postgres_locale_backup_dir}").split(" ").last
        file_path = "tmp/#{fetch :postgres_locale_backup_dir}/#{file_name}"
        
        restore_dump = "psql -U postgres #{fetch(:database_name)}< #{file_path}"
        execute restore_dump
      end
    end
  end

# Ensure that loca dirs for postgres backup exist
  before :download, :ensure_local_dirs do
    on roles(fetch(:postgres_role)) do |role|
      run_locally do
        execute :mkdir, "-p  tmp/#{fetch :postgres_backup_dir}"
        execute :mkdir, "-p  tmp/#{fetch :postgres_locale_backup_dir}"
      end
    end
  end
  
  desc 'Replecate database locally'
  task :replicate do
    invoke "postgres:backup"
    invoke "postgres:download"
    invoke "postgres:import"
  end

end