# frozen_string_literal: true

RSpec.describe Errordeck::Exception do
  it "parse from exception" do
    # create a new exception
    exception = Exception.new("test")
    exception.set_backtrace(caller)
    project_root = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
    # create the exception
    exceptions = Errordeck::Exception.parse_from_exception(exception, project_root)
    # check the exception
    expect(exceptions).to be_a(Array)
    expect(exceptions.length).to be > 0
    expect(exceptions.first).to be_a(Errordeck::Exception)
    expect(exceptions.first.type).to be_a(String)
    expect(exceptions.first.value).to be_a(String)
    expect(exceptions.first.stacktrace).to be_a(Array)
    expect(exceptions.first.stacktrace.length).to be > 0
    expect(exceptions.first.stacktrace.first).to be_a(Errordeck::Stacktrace)
    expect(exceptions.first.module).to be_a(String)
    expect(exceptions.first.thread_id).to be_a(Integer)
  end

  it "generate json" do
    # create a new exception
    exception = Exception.new("test")
    exception.set_backtrace(caller)
    project_root = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
    # create the exception
    exceptions = Errordeck::Exception.parse_from_exception(exception, project_root)
    # check the exception
    expect(exceptions.to_json).to be_a(String)
    expect(exceptions.to_json).to include("Exception")
    parsed = JSON.parse(exceptions.to_json)
    expect(parsed).to be_a(Array)
    expect(parsed.first["stacktraces"].first).to be_a(Hash)
  end
end
