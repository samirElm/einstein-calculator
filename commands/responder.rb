require_relative 'calculator'

module Commands
  class Responder
    attr_reader :data, :websocket

    def initialize(args = {})
      @data      = parse_data(args[:data])
      @websocket = args[:websocket]
    end

    def respond
      if data['type'] == 'message' && data['text'].start_with?('=')
        response = Commands::Calculator.new.evaluate(data['text']).to_s
        websocket.send({ type: 'message', text: response, channel: data['channel'] }.to_json)
      elsif data['type'] == 'message'
        response = "J'ai rien compris et inutile d'essayer la commande `help`, elle n'existe pas."
        websocket.send({ type: 'message', text: response, channel: data['channel'] }.to_json)
      end
    end

    private

    def parse_data(data)
      JSON.parse(data)
    end
  end
end
