# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
# rubocop:disable Rspec/ContextWording
RSpec.shared_context 'client mocks' do
  attr_reader :sent_evaluate_request, :sent_endorse_request, :sent_submit_request
  attr_reader :sent_proposal
  attr_reader :sent_chaincode_proposal_payload
  attr_reader :sent_chaincode_proposal_input

  def sent_chaincode_input_args
    sent_chaincode_proposal_input.chaincode_spec.input.args
  end

  attr_reader :sent_call_options

  def decode_proposal(request)
    @sent_proposal = ::Protos::Proposal.decode(request)
    @sent_chaincode_proposal_payload = ::Protos::ChaincodeProposalPayload.decode(sent_proposal.payload)
    @sent_chaincode_proposal_input = ::Protos::ChaincodeInvocationSpec.decode(sent_chaincode_proposal_payload.input)
  end

  def mock_evaluate_response(return_payload)
    mock_protos_response = object_double(::Protos::Response.new)
    allow(mock_protos_response).to receive(:payload).and_return(return_payload)
    mock_evaluate_response = object_double(::Gateway::EvaluateResponse.new)
    allow(mock_evaluate_response).to receive(:result).and_return(mock_protos_response)

    mock_evaluate_response
  end

  # probably could be moved into a shared context
  def setup_evaluate_mock(client, return_payload)
    allow(client).to receive(:evaluate) do |arg, arg2|
      expect(arg).to be_a(::Gateway::EvaluateRequest)
      decode_proposal(arg.proposed_transaction.proposal_bytes)
      @sent_evaluate_request = arg
      @sent_call_options = arg2
    end.and_return(mock_evaluate_response(return_payload))
  end
end
# rubocop:enable Metrics/BlockLength
# rubocop:enable Rspec/ContextWording
