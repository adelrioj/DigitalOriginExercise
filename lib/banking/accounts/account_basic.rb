require 'bigdecimal'
require 'bigdecimal/util'
require 'banking/accounts/account_helper'

module Banking
  module Accounts
    # AccountBasic entity represent an Account with client_name, account_number and balance,
    # and include operations to deposit and withdraw money.
    class AccountBasic
      include Banking::Accounts::AccountHelper

      DEFAULT_INITIAL_DEPOSIT = '0'.to_d.freeze

      attr_reader :client_name, :account_number, :balance

      def initialize(client_name, initial_deposit = DEFAULT_INITIAL_DEPOSIT)
        @client_name = client_name
        @account_number = create_account_number
        @balance = initial_deposit
        validate!
      end

      def deposit(amount)
        check_positive_amount!(amount)
        @balance += amount
      end

      def withdraw(amount)
        check_positive_amount!(amount)
        raise ArgumentError, 'Not enough money on the account for the requested withdraw' if amount > @balance
        @balance -= amount
      end

      private

      def validate!
        raise ArgumentError, 'Empty client_name' if @client_name.empty?
        raise ArgumentError, 'initial_deposit must be BigDecimal' unless @balance.is_a?(BigDecimal)
        check_positive_amount!(@balance)
      end
    end
  end
end
