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

  TRANSFER_TYPES = {
    intra_bank: Banking::Transfers::TransferBasic.new('+Infinity'.to_d, '0.0'.to_d, 0),
    inter_bank: Banking::Transfers::TransferBasic.new('1000.0'.to_d, '5.0'.to_d, 30)
  }.freeze

  attr_reader :account_from, :account_to, :amount, :transfers

  def initialize(account_from, account_to, amount)
    @account_from = account_from
    @account_to = account_to
    @amount = amount
    validate
    @splitted_amounts = calculate_splitted_amounts
    @transfers = []
  end

  def execute_transfer
    raise StandardError, 'not enough account balance for transfer' if @account_from.balance < full_withdraw_amount
    @splitted_amounts.each { |amount| execute_individual_transfer(amount) }
  end

  def full_withdraw_amount
    @amount + @splitted_amounts.size * transfer_type.commission
  end

  private

  def transfer_type
    if @account_from.bank == @account_to.bank
      TRANSFER_TYPES[:intra_bank]
    else
      TRANSFER_TYPES[:inter_bank]
    end
  end

  def calculate_splitted_amounts
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
    record = transfer_type.apply(@account_from, @account_to, amount)
    @transfers << record
  rescue StandardError # TODO: change to specific error
    execute_individual_transfer(amount)
  end

  def validate
    raise ArgumentError, 'amount of money must be positive' if @amount < '0'.to_d
  end
end
