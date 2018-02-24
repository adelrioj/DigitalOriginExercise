require 'bigdecimal'
require 'bigdecimal/util'
require 'banking/transfers/transfer_record'

module Banking
  module Transfers
    # Allows to perform a transfer operation with fixed values for amount_limit and commission.
    class TransferBasic

      attr_reader :amount_limit, :commission, :failure_ratio

      def initialize(amount_limit, commission, failure_ratio)
        @amount_limit = amount_limit
        @commission = commission
        @failure_ratio = failure_ratio
        validate
      end

      # this method should be TRANSACTIONAL
      def apply(account_from, account_to, amount)
        raise StandardError, 'Operation failed!' if attempt_failed?

        record = Banking::Transfers::TransferRecord.new(account_from, account_to, amount, @commission)
        withdraw_origin(record)
        deposit_destination(record)
        record
      end

      private

      def withdraw_origin(record)
        record.account_from.withdraw(record.amount + @commission)
        record.account_from.bank.add_transfer(record)
      end

      def deposit_destination(record)
        record.account_to.deposit(record.amount)
        record.account_to.bank.add_transfer(record) unless record.account_from.bank == record.account_to.bank
      end

      def attempt_failed?
        rand * 100 <= @failure_ratio
      end

      def validate
        raise ArgumentError, 'amount_limit must be BigDecimal' unless @amount_limit.is_a?(BigDecimal)
        raise ArgumentError, 'amount_limit must be positive' if @amount_limit <= '0.0'.to_d
        raise ArgumentError, 'commission must be BigDecimal' unless @commission.is_a?(BigDecimal)
        raise ArgumentError, 'commission must be >= 0.0' if @commission < '0.0'.to_d
        raise ArgumentError, 'failure_ratio must have a value between 0 and 100' if @failure_ratio < 0 || @failure_ratio > 100
      end
    end
  end
end