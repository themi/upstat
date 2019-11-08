require "extensions"

namespace :data do
  class Util
    extend Extensions::DataUtils
  end

  desc "Generate random sample (daily) stats"
  task :sample, [:folder, :years] do |t,args|

    args.with_defaults(:folder => File.expand_path("./sample.yml"), :years => 1)

    data = Util.generate_sample_data(args.years)

    Util.save_yaml(data, args.folder)
    puts "Raw (daily) stats saved to file: #{args.folder}" if verbose
  end

end
