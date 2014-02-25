module Pubnub
  class Leave
    include Pubnub::Event
    include Pubnub::SingleEvent
    include Pubnub::Formatter
    include Pubnub::Validator


    def initialize(options, app)
      super
      @event = 'leave'
      @allow_multiple_channels = true
      @doesnt_require_callback = true

    end

    def validate!
      super

      # check channel
      raise ArgumentError.new(:object => self), 'Leave requires :channel argument' unless @channel
      raise ArgumentError.new(:object => self), 'Invalid channel format! Should be type of: String, Symbol, or Array of both' unless valid_channel?
    end

    def fire(app)
      app.update_timetoken(0)
      if app.env[:subscriptions][@origin].nil?
        raise ArgumentError.new(:object => self),  'You cannot leave channel that is not subscribed'
      elsif app.env[:subscriptions][@origin].get_channels.include?(@channel)
        raise ArgumentError.new(:object => self),  'You cannot leave channel that is not subscribed'
      end
      @channel.each do |channel|
        app.env[:subscriptions][@origin].remove_channel(channel, app)
      end
      super
    end

    private

    def path(app)
      '/' + [
          'v2',
          'presence',
          'sub-key',
          @subscribe_key,
          'channel',
          @channel.join(','),
          'leave'
      ].join('/')
    end

    def format_envelopes(response, app, error)

      parsed_response = Parser.parse_json(response.body) if Parser.valid_json?(response.body)

      envelopes = Array.new
      envelopes << Envelope.new(
          {
              :message           => parsed_response,
              :response_message  => parsed_response
          },
          app
      )

      envelopes = add_common_data_to_envelopes(envelopes, response, app, error)

      envelopes

    end

  end
end