# frozen_string_literal: true

module Fabric
  #
  # Encapsulates an Envelop protobuf message
  #
  class Envelope
    # @return [Common::Envelope] transaction envelope
    attr_reader :envelope

    #
    # Creates a new Envelope instance.
    #
    # @param [Common::Envelope] envelope
    #
    def initialize(envelope)
      @envelope = envelope
    end

    #
    # Checks if the envelope has been signed.
    #
    # @return [Boolean] true if the envelope has been signed; otherwise false.
    #
    def signed?
      !envelope.signature.empty?
    end

    #
    # The protobuffer serialized form of the envelope payload.
    #
    # @return [String] serialized payload
    #
    def payload_bytes
      envelope.payload
    end

    #
    # The digest of the payload.
    #
    # @return [String] payload digest
    #
    def payload_digest
      Fabric.crypto_suite.digest(envelope.payload)
    end

    #
    # Sets the envelope signature.
    #
    # @param [String] signature
    #
    # @return [Void]
    #
    def signature=(signature)
      envelope.signature = signature
    end

    def result
      @result ||= parse_result_from_payload
    end

    #
    # Returns the deserialized payload.
    #
    # @return [Common::Payload] Envelope payload
    #
    def payload
      @payload ||= Common::Payload.decode(envelope.payload)
    end

    #
    # Returns the envelope payload header.
    #
    # Envelope => Payload => Header
    #
    # @return [Common::Header] Envelope Payload Header
    #
    def header
      raise Fabric::Error, 'Missing header' if payload.header.nil?

      @header ||= payload.header
    end

    #
    # Returns the deserialized transaction channel header
    #
    # Envelope => Payload => Header => ChannelHeader
    #
    # @return [Common::ChannelHeader] envelop payload header channel header
    #
    def channel_header
      @channel_header ||= Common::ChannelHeader.decode(header.channel_header)
    end

    #
    # Grabs the channel_name frmo the depths of the envelope.
    #
    # @return [String] channel name
    #
    def channel_name
      channel_header.channel_id
    end

    #
    # Returns the deserialized transaction
    #
    # @return [Protos::Transaction] transaction
    #
    def transaction
      @transaction ||= Protos::Transaction.decode(payload.data)
    end

    private

    #
    # Parse the transaction actinos from the payload looking for the transaction result payload.
    #
    # @return [String] result payload
    # @raise [Fabric::Error] if the transaction result payload is not found
    #
    def parse_result_from_payload
      errors = []
      transaction.actions.each do |action|
        return parse_result_from_transaction_action(action)
      rescue Fabric::Error => e
        errors << e
      end

      raise Fabric::Error, "No proposal response found: #{errors.inspect}"
    end

    #
    # Parse a single transaction action looking for the transaction result payload.
    #
    # @param [Protos::TransactionAction] transaction_action
    #
    # @return [Payload] transaction result payload
    # @raise [Fabric::Error] if the endorsed_action is missing or the chaincode response is missing
    #
    def parse_result_from_transaction_action(transaction_action)
      action_payload = Protos::ChaincodeActionPayload.decode(transaction_action.payload)
      endorsed_action = action_payload.action
      raise Fabric::Error, 'Missing endorsed action' if endorsed_action.nil?

      response_payload = Protos::ProposalResponsePayload.decode(endorsed_action.proposal_response_payload)
      chaincode_action = Protos::ChaincodeAction.decode(response_payload.extension)
      chaincode_response = chaincode_action.response
      raise Fabric::Error, 'Missing chaincode response' if chaincode_response.nil?

      chaincode_response.payload
    end
  end
end
