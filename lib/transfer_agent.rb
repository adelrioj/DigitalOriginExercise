# frozen_string_literal: true
require 'banking/version'
# bank
require 'banking/bank'
# accounts
require 'banking/accounts/account_basic'
# transfers
require 'banking/transfers/transfer_record'
require 'banking/transfers/transfer_basic'

# Simulates the operations of a transfer agent, that assures that everybody gets their money.
# When the agent receives an order to transfer money from account A to account B,
# he issues transfers considering commissions, transfer limits and possibility of transfer failures.
class TransferAgent

  attr_reader :transfer_types

  def initialize(transfer_types)
    @transfer_types = transfer_types
  end

  def execute_transfer(account_from, account_to, amount)
    @account_from = account_from
    @account_to = account_to
    @amount = amount
    @transfer_records = []
    validate
    splitted_amounts.each do |amount|
      record = execute_individual_transfer(amount)
      @transfer_records << record
    end
    @transfer_records
  end

  def full_withdraw_amount
    @amount + splitted_amounts.size * transfer_type.commission
  end

  private

  def transfer_type
    if @account_from.bank == @account_to.bank
      @transfer_types[:intra_bank]
    else
      @transfer_types[:inter_bank]
    end
  end

  def splitted_amounts
    remaining_amount = @amount
    amounts = []

    while remaining_amount.positive?
      if remaining_amount < transfer_type.amount_limit
        amounts << remaining_amount
        remaining_amount = 0
      else
        amounts << transfer_type.amount_limit
        remaining_amount -= transfer_type.amount_limit
      end
    end
    amounts
  end

  def execute_individual_transfer(amount)
    transfer_type.apply(@account_from, @account_to, amount)
  rescue StandardError # TODO: change to specific error
    execute_individual_transfer(amount)
  end

  def validate
    raise ArgumentError, 'amount of money must be positive' if @amount < '0'.to_d
    raise StandardError, 'not enough account balance for transfer' if @account_from.balance < full_withdraw_amount
  end
end
