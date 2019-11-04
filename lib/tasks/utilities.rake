require "extensions"

namespace :data do
  class Util
    extend Extensions::Utils
  end

  desc "Generate random sample (daily) stats"
  task :sample, [:folder, :years] do |t,args|

    args.with_defaults(:folder => File.expand_path("./sample.yml"), :years => 1)

    Util.generate_sample_data args.folder, args.years
  end

end
