namespace :data do
  desc 'Initiate Default Data'
  task :all do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'data:all'
        end
      end
    end
  end
end