module Upstat
  class DataTable
    extend Extensions::Utils

    def self.open(file_name)
      if defined?(ActiveRecord) && file_name.class.ancestors.include?(ActiveRecord::Base)
        file_name

      elsif file_name.is_a?(String)
        ename = File.extname(File.expand_path(file_name))

        data = if [".yaml", ".yml"].include?(ename)
          get_yaml(file_name)
        elsif [".json"].include?(ename)
          get_json(file_name)
        end
        DataTable.new(data)

      elsif file_name.is_a?(Array)
        DataTable.new(file_name.to_openstruct)

      end
    end

    attr_reader :head, :tail

    def initialize(head, tail = nil)
      @head, @tail = head, tail
    end

    def <<(item)
      DataTable.new(item, self)
    end

    def each(&block)
      block.call(@head)
      @tail.each(&block) if @tail
    end

    def inspect
      [@head, @tail].inspect
    end
  end
end
