require 'bigdecimal'
require 'bigdecimal/util'
require 'banking/transfers/transfer_helper'

module Banking
  module Transfers
    # Models a transference between accounts of the same bank
    class TransferIntraBank
      include Banking::Transfers::TransferHelper

      attr_reader :account_from, :account_to, :amount

      def initialize(account_from, account_to, amount)
        @account_from = account_from
        @account_to = account_to
        @amount = amount
        validate!
      end

      def apply
        @account_from.withdraw(@amount)
        @account_to.deposit(@amount)
        @status = STATUS_SUCCESS
        @account_from.bank.add_transfer(self)
        self
      rescue ArgumentError => e
        @status = STATUS_FAIL
        raise e
      end

      def succeeded?
        @status == STATUS_SUCCESS
      end

      def amount_limit
        Float::INFINITY
      end

      def commission
        '0.0'.to_d
      end

      def total_amount
        @amount + commission
      end

      private

      def validate!
        raise ArgumentError, 'amount of money must be positive' if @amount < '0'.to_d
        raise ArgumentError, 'Accounts must be different' if @account_from == @account_to
        raise ArgumentError, 'Banks must be the same' unless @account_from.bank == @account_to.bank
        validate_account!(@account_from)
        validate_account!(@account_to)
      end
    end
  end
end
