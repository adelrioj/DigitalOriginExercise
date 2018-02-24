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

    @full_iterations = calculate_full_iterations
    @transfers = []
  end

  def execute_transfer
    raise StandardError, 'not enough account balance for transfer' if @account_from.balance < full_withdraw_amount

    determine_execute_transfer
    @transfers
  end

  def transfer_splitted?
    @amount > transfer_type.amount_limit
  end

  def full_withdraw_amount
    iterations = @amount + @full_iterations * transfer_type.commission
    iterations += transfer_type.commission if last_iteration_amount > '0.0'.to_d
    iterations
  end

  private

  def transfer_type
    if @account_from.bank == @account_to.bank
      TRANSFER_TYPES[:intra_bank]
    else
      TRANSFER_TYPES[:inter_bank]
    end
  end

  def determine_execute_transfer
    if transfer_splitted?
      execute_splitted_transfer
    else
      execute_individual_transfer(@amount)
    end
  end

  def calculate_full_iterations
    (@amount / transfer_type.amount_limit).to_i
  end

  def last_iteration_amount
    @amount % transfer_type.amount_limit
  end

  def execute_splitted_transfer
    @full_iterations.times { |_i| execute_individual_transfer(transfer_type.amount_limit) }
    execute_individual_transfer(last_iteration_amount) unless last_iteration_amount.zero?
  end

  def execute_individual_transfer(amount)
    record = transfer_type.apply(@account_from, @account_to, amount)
    @transfers << record
  rescue StandardError
    execute_individual_transfer(amount)
  end

  def validate
    raise ArgumentError, 'amount of money must be positive' if @amount < '0'.to_d
  end
end
