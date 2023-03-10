RSpec.describe Errordeck::Event do
  let(:level) { "error" }
  let(:transaction) { "test-transaction" }
  let(:message) { "test error message" }

  subject(:event) do
    described_class.new(
      level: level,
      transaction: transaction,
      message: message
    )
  end

  describe "#to_json" do
    it "returns a JSON object with the correct attributes" do
      expected_json = {
        event_id: event.id,
        timestamp: event.timestamp.to_i,
        platform: :ruby,
        level: level,
        logger: :ruby,
        transaction: transaction,
        server_name: nil,
        release: nil,
        dist: nil,
        environment: "development",
        message: message,
        modules: nil,
        extra: nil,
        exceptions: nil,
        contexts: nil,
        request: nil,
        sdk: Errordeck::Event::SDK,
        user: nil
      }.to_json
      expect(event.to_json).to eq(expected_json)
    end
  end
end
