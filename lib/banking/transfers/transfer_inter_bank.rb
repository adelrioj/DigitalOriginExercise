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
        validate
      end

      def apply
        if attempt_succeeded?
          @account_from.withdraw(@amount + self.class.commission)
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

      def to_s
        "account from: #{@account_from}\naccount to: #{@account_to}\namount: #{pretiffy_amount(@amount)}€"
      end

      def self.amount_limit
        '1000.0'.to_d
      end

      def self.commission
        '5.0'.to_d
      end

      private

      def attempt_succeeded?
        failure_ratio_percent = 30
        rand * 100 > failure_ratio_percent
      end

      def validate
        validate_account(@account_from)
        validate_account(@account_to)
        raise ArgumentError, 'amount of money must be positive' if @amount < '0'.to_d
        raise ArgumentError, 'amount of money must be below or equal limit' if @amount > self.class.amount_limit
        raise ArgumentError, 'Accounts must be different' if @account_from == @account_to
        raise ArgumentError, 'Banks must be different' if @account_from.bank == @account_to.bank
      end
    end
  end
end
