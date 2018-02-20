require 'bigdecimal'
require 'bigdecimal/util'
require 'banking/transfers/transfer_helper'

module Banking
  module Transfers
    # Models a transference between accounts of two different banks
    class TransferInterBank
      include Banking::Transfers::TransferHelper

      attr_reader :account_from, :account_to, :amount

      def initialize(account_from, account_to, amount)
        @account_from = account_from
        @account_to = account_to
        @amount = amount
        validate!
      end

      def apply
        if attempt_succeeded?
          @account_from.withdraw(total_amount)
          @account_to.deposit(@amount)
          @account_from.bank.add_transfer(self)
          @account_to.bank.add_transfer(self)
          @status = STATUS_SUCCESS
        else
          @status = STATUS_FAIL
        end
        self
      rescue ArgumentError => e
        @status = STATUS_FAIL
        raise e
      end

      def succeeded?
        @status == STATUS_SUCCESS
      end

      def amount_limit
        '1000.0'.to_d
      end

      def commision
        '5.0'.to_d
      end

      def total_amount
        @amount + commision
      end

      private

      def attempt_succeeded?
        failure_ratio_percent = 30
        rand * 100 > failure_ratio_percent
      end

      def validate!
        raise ArgumentError, 'amount of money must be positive' if @amount < '0'.to_d
        raise ArgumentError, 'amount of money must be <= amount_limit' if @amount > amount_limit
        raise ArgumentError, 'Accounts must be different' if @account_from == @account_to
        raise ArgumentError, 'Banks must be different' if @account_from.bank == @account_to.bank
        validate_account!(@account_from)
        validate_account!(@account_to)
      end
    end
  end
end
