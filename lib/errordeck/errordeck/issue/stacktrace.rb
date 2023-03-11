# frozen_string_literal: true

require "json"
module Errordeck
  class Stacktrace
    attr_accessor :abs_path, :function, :in_app, :filename, :lineno, :module, :vars

    def initialize(project_root, line)
      @abs_path = line.file
      @function = line.method
      @in_app = line.file.start_with?(project_root)
      @filename = File.basename(line.file)
      @lineno = line.line
      @module = line.module_name
      @vars = {}
    end

    def as_json(*_options)
      {
        abs_path: @abs_path,
        function: @function,
        in_app: @in_app,
        filename: @filename,
        lineno: @lineno,
        module: @module,
        vars: @vars
      }
    end

    def to_json(*options)
      JSON.generate(as_json, *options)
    end

    def self.parse_from_backtrace(backtrace, project_root = nil)
      project_root ||= File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
      error_backtrace = Errordeck::Backtrace.parse(backtrace)

      return nil if error_backtrace.nil?

      frames = []
      error_backtrace.lines.each do |line|
        frames << new(project_root, line)
      end

      frames
    end
  end
end
