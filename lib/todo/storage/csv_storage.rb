class Todo
  module Storage
    class CSVStorage
      def initialize(file)
        @file = file
      end

      def read
        tasks = []

        CSV.foreach @file, headers: true, header_converters: :symbol do |row|
          task = row.to_h
          task[:done] = task[:done] == 'true' if task.key? :done
          tasks << task
        end

        tasks
      rescue Errno::ENOENT
        raise TodoFileReadError.new("No such file: #{@file}.")
      rescue Errno::EACCES
        raise TodoFileReadError.new("No permissions: #{@file} ")
      rescue CSV::MalformedCSVError
        raise TodoFileReadError.new("Malformed CSV: #{@file}.")
      end

      def write(data)
        headers = data.first&.keys
        return if headers.nil?

        CSV.open @file, 'w', write_headers: true, headers: headers do |csv|
          data.each do |task|
            csv << headers.map { |header| task[header] }
          end
        end
      rescue Errno::ENOENT
        raise TodoFileReadError.new("Unable to open #{@file} file. No such file.")
      rescue Errno::EACCES
        raise TodoFileReadError.new("Unable to read #{@file} file. No permissions.")
      end
    end
  end
end
