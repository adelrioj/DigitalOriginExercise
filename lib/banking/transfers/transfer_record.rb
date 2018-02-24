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

      def to_s
        "account from: #{@account_from}\naccount to: #{@account_to}\namount: #{pretiffy_amount(@amount)}€"
      end

      private

      def validate
        raise ArgumentError, 'amount of money must be positive' if @amount < '0.0'.to_d
        raise ArgumentError, 'Accounts must be different' if @account_from == @account_to
      end

      def pretiffy_amount(amount)
        (amount.to_f * 100).to_i / 100.0
      end
    end
  end
end