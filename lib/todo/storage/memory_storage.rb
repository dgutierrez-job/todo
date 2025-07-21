class Todo
  module Storage
    class MemoryStorage
      def initialize(file = [])
        @file = file || []
      end

      def read
        @file
      end

      def write(data)
        @file = data
      end
    end
  end
end
