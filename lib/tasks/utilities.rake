require "yaml"
require "extensions"

namespace :data do

  desc "Generate random daily stats"
  task :daily_stats, [:folder, :years] do |t,args|

    args.with_defaults(:folder => "./raw_data.yml", :years => 1)

    Extensions::Utils.generate_raw_data args.folder, args.years
  end

end
