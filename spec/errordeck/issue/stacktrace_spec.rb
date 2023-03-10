# frozen_string_literal: true

RSpec.describe Errordeck::Stacktrace do
  it "create from backtrace" do
    # create a new exception
    exception = Exception.new("test")
    exception.set_backtrace(caller)
    # create the stacktrace
    stacktrace = Errordeck::Stacktrace.parse_from_backtrace(exception.backtrace)
    # check the stacktrace
    expect(stacktrace).to be_a(Array)
    expect(stacktrace.length).to be > 0
    expect(stacktrace.first).to be_a(Errordeck::Stacktrace)
    expect(stacktrace.first.filename).to be_a(String)
    expect(stacktrace.first.lineno).to be_a(Integer)
    expect(stacktrace.first.module).to be_a(String)
  end

  it "generate json" do
    # create a new exception
    exception = Exception.new("test")
    exception.set_backtrace(caller)
    project_root = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
    # create the stacktrace
    stacktrace = Errordeck::Stacktrace.parse_from_backtrace(exception.backtrace, project_root)
    # check the stacktrace
    expect(stacktrace.to_json).to be_a(String)
    expect(stacktrace.to_json).to include("abs_path")
  end
end
