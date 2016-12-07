def load_seeds(datatype)
  realtime = Benchmark.realtime do |bm|
    load "db/#{datatype}.rb"
  end
  puts "Time: #{datatype} -  #{realtime.round(3)} seconds"
end

namespace :fakers do
  DATA_FAKERS_FILES = ['fakers']
  desc 'Seed Default Data'

  task :all => :environment do

    DATA_FAKERS_FILES.each { |datatype| load_seeds(datatype) }
  end

end
