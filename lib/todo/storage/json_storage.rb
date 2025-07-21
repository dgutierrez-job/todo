class Todo
  module Storage
    class JSONStorage
      def initialize(file)
        @file = file
      end

      def read
        JSON.parse(File.read(@file), { symbolize_names: true })
      rescue Errno::ENOENT
        raise TodoFileReadError.new("Unable to open #{@file} file. No such file.")
      rescue Errno::EACCES
        raise TodoFileReadError.new("Unable to read #{@file}. No permissions.")
      rescue JSON::ParserError
        raise TodoFileReadError.new("JSON malformed on #{@file} file")
      rescue StandardError => e
        raise TodoError.new("Unexpected error: #{e.message}")
      end

      def write(data)
        JSON.dump data, File.open(@file, 'w')
      rescue Errno::ENOENT
        raise TodoFileReadError.new("Unable to open #{@file} file. No such file.")
      rescue Errno::EACCES
        raise TodoFileReadError.new("Unable to write in #{@file}. No permissions")
      end
    end
  end
end
