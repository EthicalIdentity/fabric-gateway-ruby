# frozen_string_literal: true

module Fabric
  #
  # Encapsulates an Envelop message
  #
  # @todo - missing tests :(
  class Envelope
    # @return [Common::Envelope] transaction envelope
    attr_reader :envelope

    def initialize(envelope)
      @envelope = envelope
    end

    def signed?
      !envelope.signature.empty?
    end

    def payload_bytes
      envelope.payload
    end

    def payload_digest
      Fabric.crypto_suite.digest(envelope.payload)
    end

    def signature=(signature)
      envelope.signature = signature
    end

    def result
      @result ||= parse_result_from_payload
    end

    def payload
      @payload ||= Common::Payload.decode(envelope.payload)
    end

    def channel_name
      header.channel_id
    end

    def header
      raise Fabric::Error, 'Missing header' if payload.header.empty?

      @header ||= Common::Header.decode(payload.header)
    end

    def transaction
      @transaction ||= Protos::Transaction.decode(payload.data)
    end

    def parse_result_from_payload
      errors = []
      transaction.actions.each do |action|
        return parse_result_from_transaction_action(action)
      rescue Fabric::Error => e
        errors << e
      end

      raise Fabric::Error, "No proposal response found: #{errors.inspect}"
    end

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
