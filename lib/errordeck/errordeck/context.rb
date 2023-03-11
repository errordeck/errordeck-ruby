# frozen_string_literal: true

require "etc"
module Errordeck
  # context to set OS context and runtime context
  class Context
    def self.runtime
      { name: "ruby", version: RUBY_VERSION }
    end

    def self.os
      uname = Etc.uname
      {
        name: uname[:sysname] || RbConfig::CONFIG["host_os"],
        version: uname[:version],
        build: uname[:build],
        kernel_version: uname[:version]
      }.compact
    end

    # get context
    def self.context
      { os: os, runtime: runtime }.compact
    end
  end
end
