module Fabric
  #
  # Status of a transaction that is committed to the ledger.
  # @todo - test me! this is very trivial, so it might be a good idea
  #   for a first time tester or someone new to the project
  #
  class Status
    TRANSACTION_STATUSES = ::Protos::TxValidationCode.constants.map(&::Protos::TxValidationCode.method(:const_get)).collect do |i|
      [::Protos::TxValidationCode.lookup(i), i]
    end.to_h

    # @return [Integer] Block number in which the transaction committed.
    attr_reader :block_number

    # @return [Integer] Transaction status
    attr_reader :code

    # @return [Boolean] `true` if the transaction committed successfully; otherwise `false`.
    attr_reader :successful

    # @return [String] The ID of the transaction.
    attr_reader :transaction_id

    def initialize(transaction_id, block_number, code)
      @transaction_id = transaction_id
      @block_number = block_number
      @code = code
      @successful = @code == TRANSACTION_STATUSES[:VALID]
    end
  end
end
