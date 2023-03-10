# frozen_string_literal: true

RSpec.describe Errordeck::Backtrace do
  # parse an exception backtrace and return array of Backtrace::Line
  it "parses an exception backtrace is nil" do
    # create a new exception
    exception = Exception.new("test")
    # parse the backtrace
    backtrace = Errordeck::Backtrace.parse(exception.backtrace)
    # check the backtrace
    expect(backtrace).to be_nil
  end

  it "parses an exception backtrace" do
    # create a new exception
    exception = Exception.new("test")
    exception.set_backtrace(caller)
    # parse the backtrace
    backtrace = Errordeck::Backtrace.parse(exception.backtrace)

    # check the backtrace
    expect(backtrace).to be_a(Errordeck::Backtrace)
    expect(backtrace.lines).to be_a(Array)
    expect(backtrace.lines.length).to be > 0
    expect(backtrace.lines.first).to be_a(Errordeck::Backtrace::Line)
    expect(backtrace.lines.first.line).to be_a(Integer)
    expect(backtrace.lines.first.method).to be_a(String)
    expect(backtrace.lines.first.module_name).to eq("example.rb")
    expect(backtrace.lines.first.in_app).to be(true)
  end
end
