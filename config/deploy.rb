# config valid only for current version of Capistrano
lock '3.4.1'

set :scm, :git

set :format, :pretty

set :log_level, :debug

set :pty, true

set :branch, ask('Enter Git Branch:', 'master')

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml',
                                                 '.env.development',
                                                 '.env.production',
                                                 '.env.staging',
                                                 'config/cable.yml',
                                                 'config/schedule.rb',
                                                 'config/environments/development.rb',
                                                 'config/environments/staging.rb',
                                                 'config/environments/production.rb',
                                                 'config/environments/test.rb')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log',
                                               'tmp/pids',
                                               'tmp/cache',
                                               'tmp/sockets',
                                               'vendor/bundle',
                                               'public/system')

set :rvm_type, :user
set :rvm_ruby_version, '2.3.1@hooleyapi'

set :bundle_gemfile, -> { release_path.join('Gemfile') }
set :bundle_path, nil
set :bundle_binstubs, nil
set :bundle_flags, ''
set :bundle_without, nil

set :sidekiq_config, File.join(current_path, 'config', 'sidekiq.yml')
set :sidekiq_options_per_process, ["--queue default --queue mailers"]

# set :passenger_instance_name, ask('Remote Passenger Instance:', '', echo: true)
# set :passenger_restart_options, -> { "--instance #{fetch(:passenger_instance_name)}"  }
# set :passenger_restart_with_touch, true


# Default value for keep_releases is 5
set :keep_releases, 10

namespace :deploy do

  # before 'deploy:starting', 'postgres:backup'
  # after 'deploy:restart', 'standalone_passenger:restart'

end