# frozen_string_literal: true

require "json"

module Errordeck
  class Stacktrace
    attr_accessor :abs_path, :function, :in_app, :filename, :lineno, :module, :vars, :context_line, :pre_context,
                  :post_context

    def initialize(project_root, line)
      @abs_path = line.file
      @function = line.method
      @in_app = line.file.start_with?(project_root)
      @filename = File.basename(line.file)
      @lineno = line.line
      @module = line.module_name
      @vars = {}
      set_contexts(line.file, line.line)
    end

    def as_json(*_options)
      {
        abs_path: @abs_path,
        function: @function,
        in_app: @in_app,
        filename: @filename,
        lineno: @lineno,
        module: @module,
        vars: @vars,
        context_line: @context_line,
        pre_context: @pre_context,
        post_context: @post_context
      }
    end

    def to_json(*options)
      JSON.generate(as_json, *options)
    end

    def self.parse_from_backtrace(backtrace, project_root = nil)
      project_root ||= File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
      error_backtrace = Errordeck::Backtrace.parse(backtrace)
      return nil if error_backtrace.nil?

      error_backtrace.lines.map { |line| new(project_root, line) }
    end

    private

    def set_contexts(file, line_number)
      return unless File.exist?(file)

      source = File.readlines(file)
      return if source.empty?

      range_start = [line_number - 5, 0].max
      range_end = [line_number + 3, source.length - 1].min

      @pre_context = source[range_start...line_number - 1]
      @context_line = source[line_number - 1]
      @post_context = source[line_number...range_end + 1]
    end
  end
end
