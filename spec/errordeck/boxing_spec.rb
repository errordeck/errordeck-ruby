# frozen_string_literal: true

RSpec.describe Errordeck::Boxing do
  let(:boxing) { Errordeck::Boxing.new }
  let(:transaction) { boxing.transaction }
  let(:request) { boxing.request }
  let(:user) { boxing.user }
  let(:tags) { boxing.tags }
  let(:modules) { boxing.modules }
  let(:context) { boxing.context }

  describe "#initialize" do
    it "should set transaction to nil" do
      expect(transaction).to be_nil
    end

    it "should set request to nil" do
      expect(request).to be_nil
    end

    it "should set user to nil" do
      expect(user).to be_nil
    end

    it "should set tags to nil" do
      expect(tags).to be_nil
    end

    it "should set modules to be a hash" do
      expect(modules).to be_a(Hash)
    end

    it "should set context to be a hash" do
      expect(context).to be_a(Hash)
    end
  end

  describe "#capture" do
    let(:exception) { StandardError.new("test") }
    let(:user) { { id: 1, email: "test@example.com" } }
    let(:tags) { { tag: "test" } }

    it "should set event to generate_from_exception" do
      boxing.capture(exception, user, tags)
      error_event = boxing.error_event
      expect(error_event).to be_a(Errordeck::Event)
      expect(error_event.level).to eq("error")
      expect(error_event.message).to eq("test")
    end

    it "should set user context" do
      boxing.capture(exception, user, tags)
      error_event = boxing.error_event
      expect(error_event.user).to eq(user)
    end

    it "should set tags context" do
      boxing.capture(exception, user, tags)
      error_event = boxing.error_event
      expect(error_event.tags).to eq(tags)
    end

    it "should set request context" do
      boxing.capture(exception, user, tags)
      error_event = boxing.error_event
      expect(error_event.request).to eq(request)
    end
  end

  describe "#message" do
    let(:level) { "error" }
    let(:message) { "test" }
    let(:extra) { { extra: "test" } }
    let(:error_event) { boxing.message(level, message, extra) }

    it "should set event to generate_event" do
      expect(error_event).to be_a(Errordeck::Event)
      expect(error_event.level).to eq(level)
      expect(error_event.message).to eq(message)
      expect(error_event.extra).to eq(extra)
    end

    it "should set user context" do
      expect(error_event.user).to eq(user)
    end

    it "should set tags context" do
      expect(error_event.tags).to eq(tags)
    end

    it "should set request context" do
      expect(error_event.request).to eq(request)
    end
  end

  describe "#set_transaction" do
    let(:transaction) { "test" }

    it "should set transaction" do
      boxing.set_transaction(transaction)
      expect(boxing.transaction).to eq(transaction)
    end
  end

  describe "#set_request" do
    let(:request) { "test" }

    it "should set request" do
      boxing.set_request(request)
      expect(boxing.request).to eq(request)
    end
  end

  describe "#user_context" do
    let(:user) { { id: 1, email: "test@example.com" } }

    it "should set user" do
      boxing.user_context = user
      expect(boxing.user).to eq(user)
    end
  end

  describe "#tags_context" do
    let(:tags) { { tag: "test" } }

    it "should set tags" do
      boxing.tags_context = tags
      expect(boxing.tags).to eq(tags)
    end
  end

  describe "#context" do
    let(:context) { { context: "test" } }

    it "should set context" do
      boxing.context = context
      expect(boxing.context).to eq(context)
    end
  end
end
