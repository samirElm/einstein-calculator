require 'http'
require 'json'
require 'faye/websocket'

module Slack
  class WebSocket
    attr_reader :code, :token

    def initialize(code)
      @code  = code
      @token = retrieve_access_token
    end

    def call
      Faye::WebSocket::Client.new(retrieve_websocket_url)
    end

    private

    def retrieve_access_token
      request_access_token['bot']['bot_access_token']
    end

    def request_access_token
      JSON.parse(HTTP.post('https://slack.com/api/oauth.access', params: {
        client_id: ENV["SLACK_CLIENT_ID"],
        client_secret: ENV["SLACK_CLIENT_SECRET"],
        code: code
      }))
    end

    def retrieve_websocket_url
      call_slack_rtm['url']
    end

    def call_slack_rtm
      JSON.parse(HTTP.post('https://slack.com/api/rtm.start', params: {
        token: token
      }))
    end
  end
end
