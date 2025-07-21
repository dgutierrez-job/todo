class Todo
  module Entities
    class Entity
      def initialize(record)
        @record = record
      end

      def deleted?
        !record[:deleted_at].nil?
      end

      def to_json( ... )
        record.to_json( ... )
      end

      private

      attr_reader :record

      def method_missing(method, ...)
        super unless record.key? method

        record[method]
      end

      def respond_to_missing?(method, _)
        record.key? method
      end
    end
  end
end

require_relative 'entities/user'
require_relative 'entities/task'
