# frozen_string_literal: true

module Errordeck
  class Exception
    attr_accessor :type, :value, :stacktrace, :module, :thread_id

    def initialize(type, value, stacktrace, module_name, thread_id)
      @type = type
      @value = value
      @stacktrace = stacktrace
      @module = module_name
      @thread_id = thread_id
    end

    def self.parse_from_exception(exception, project_root)
      exception_type = exception.class.to_s
      exception_value = exception.message
      exception_stacktrace = Errordeck::Stacktrace.parse_from_backtrace(exception.backtrace, project_root)
      exception_module = exception_type.split("::")[0]
      exception_thread_id = Thread.current.object_id

      [new(exception_type, exception_value, exception_stacktrace, exception_module, exception_thread_id)]
    end

    def as_json(*_options)
      {
        type: @type,
        value: @value,
        stacktraces: @stacktrace,
        module: @module,
        thread_id: @thread_id
      }
    end

    def to_json(*options)
      JSON.generate(as_json, *options)
    end
  end
end
