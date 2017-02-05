require_relative 'calculator'

module Commands
  class Responder
    attr_reader :data, :websocket

    def initialize(args = {})
      @data      = parse_data(args[:data])
      @websocket = args[:websocket]
    end

    def respond
      if message_starts_with_equal?
        websocket.send({ type: 'message', text: result, channel: data['channel'] }.to_json)
      end
    end

    private

    def parse_data(data)
      JSON.parse(data)
    end

    def message_starts_with_equal?
      data['type'] == 'message' && data['text'].start_with?('=')
    end

    def result
      Commands::Calculator.new.evaluate(data['text']).to_s
    end
  end
end
