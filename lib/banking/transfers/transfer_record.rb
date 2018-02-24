require 'bigdecimal'
require 'bigdecimal/util'

module Banking
  module Transfers
    # Model for a transference operation, performed by any type of transfer.
    # Used to store a record of the transfer.
    class TransferRecord

      attr_reader :account_from, :account_to, :amount, :commission

      def initialize(account_from, account_to, amount, commission)
        @account_from = account_from
        @account_to = account_to
        @amount = amount
        @commission = commission
        validate
      end

      private

      def validate
        raise ArgumentError, 'amount of money must be positive' if @amount < '0.0'.to_d
        raise ArgumentError, 'commission must be >= 0.0' if @commission <= '0.0'.to_d
        raise ArgumentError, 'Accounts must be different' if @account_from == @account_to
      end
    end
  end
end