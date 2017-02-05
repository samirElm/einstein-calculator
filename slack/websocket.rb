require 'http'
require 'json'
require 'faye/websocket'

module Slack
  class WebSocket
    attr_reader :code

    def initialize(code)
      @code = code
    end

    def call
      rc = JSON.parse(HTTP.post('https://slack.com/api/oauth.access', params: {
        client_id: ENV["SLACK_CLIENT_ID"],
        client_secret: ENV["SLACK_CLIENT_SECRET"],
        code: code
      }))

      token = rc['bot']['bot_access_token']

      rc = JSON.parse(HTTP.post('https://slack.com/api/rtm.start', params: {
        token: token
      }))

      url = rc['url']

      return Faye::WebSocket::Client.new(url)
    end
  end
end
