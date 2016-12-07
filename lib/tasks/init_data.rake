def load_seeds(datatype)
  realtime = Benchmark.realtime do |bm|
    load "db/#{datatype}.rb"
  end
  puts "Time: #{datatype} -  #{realtime.round(3)} seconds"
end

namespace :data do
  DATA_SEED_FILES = ['countries']

  desc 'Seed Default Data'

  task :all => :environment do
    DATA_SEED_FILES.each { |datatype| load_seeds(datatype) }
  end

end
