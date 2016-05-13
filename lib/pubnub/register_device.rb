# Toplevel Pubnub module.
module Pubnub
  # Holds where_now functionality
  class RegisterDevice < SingleEvent
    include Celluloid
    include Pubnub::Validator::RegisterDevice

    def initialize(options, app)
      @event = :register_device
      @device_token = options[:device_token]
      @action = @action.to_sym unless @action.nil?
      @type = @type.to_sym unless @type.nil?
      super
    end

    private

    def path
      '/' + [
        'v1',
        'push',
        'sub-key',
        @subscribe_key,
        'devices',
        @device_token,
      ].join('/')
    end

    def parameters
      parameters = super
      return parameters if @channel.blank?
      case @action
      when :add
        parameters.merge!(add: @channel.join(','))
      when :remove
        parameters.merge!(remove: @channel.join(','))
      when :list
        parameters.merge!(list: @channel.join(','))
      end
      # Add type if it's specified
      parameters.merge!(type: @type) if @type
      parameters
    end

    def format_envelopes(response)
      parsed_response, error = Formatter.parse_json(response.body)

      error = response if parsed_response && response.code.to_i != 200

      envelopes = if error
                    [error_envelope(parsed_response, error)]
                  else
                    [valid_envelope(parsed_response)]
                  end

      add_common_data_to_envelopes(envelopes, response)
    end

    def valid_envelope(parsed_response)
      Envelope.new(
        parsed_response: parsed_response,
        payload:         parsed_response['payload'],
        service:         parsed_response['service'],
        message:         parsed_response['message'],
        status:          parsed_response['status']
      )
    end

    def error_envelope(parsed_response, error)
      ErrorEnvelope.new(
        error:            error,
        response_message: response_message(parsed_response),
        channel:          @channel.first,
        timetoken:        timetoken(parsed_response)
      )
    end
  end
end