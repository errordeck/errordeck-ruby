# frozen_string_literal: true

RSpec.describe Errordeck::Context do
  it "has a runtime" do
    expect(Errordeck::Context.runtime).to eq({
                                               name: "ruby",
                                               version: RUBY_VERSION
                                             })
  end

  it "has an os" do
    uname = Etc.uname
    expect(Errordeck::Context.os).to eq({
      name: uname[:sysname] || RbConfig::CONFIG["host_os"],
      version: uname[:version],
      build: uname[:build],
      kernel_version: uname[:version]
    }.compact)
  end

  it "has a context" do
    expect(Errordeck::Context.context).to eq({
                                               os: Errordeck::Context.os,
                                               runtime: Errordeck::Context.runtime
                                             })
  end
end
