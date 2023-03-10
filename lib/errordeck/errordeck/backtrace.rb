# frozen_string_literal: true

require "json"

module Errordeck
  class Backtrace
    Line = Struct.new(:file, :line, :method, :module_name, :in_app) do
      RB_EXTENSION = ".rb"
      RUBY_INPUT_FORMAT = /
        ^ \s* (?: [a-zA-Z]: | uri:classloader: )? ([^:]+ | <.*>):
        (\d+)
        (?: :in \s `([^']+)')?$
      /x.freeze

      def self.parse(unparsed_line)
        file, line, method = unparsed_line.match(RUBY_INPUT_FORMAT).captures
        file.sub!(/\.class$/, RB_EXTENSION)
        module_name = File.basename(file, ".*") + RB_EXTENSION

        in_app = %w[bin exe app config lib test].any? { |dir| file.include?(dir) }

        new(file, line.to_i, method, module_name, in_app)
      end
    end

    attr_reader :lines

    def self.parse(backtrace)
      return nil if backtrace.nil?

      lines = backtrace.map(&:chomp).map { |line| Line.parse(line) }

      new(lines)
    end

    def initialize(lines)
      @lines = lines
    end
  end
end
