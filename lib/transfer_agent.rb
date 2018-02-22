# frozen_string_literal: true
require 'banking/version'
# bank
require 'banking/bank'
# accounts
require 'banking/accounts/account_basic'
# transfers
require 'banking/transfers/transfer_intra_bank'
require 'banking/transfers/transfer_inter_bank'
require 'banking/transfers/transfer_helper'

# Simulates the operations of a transfer agent, that assures that everybody gets their money.
# When the agent receives an order to transfer money from account A to account B,
# he issues transfers considering commissions, transfer limits and possibility of transfer failures.
class TransferAgent
  include Banking::Transfers::TransferHelper

  attr_reader :account_from, :account_to, :amount, :transfers

  def initialize(account_from, account_to, amount)
    @account_from = account_from
    @account_to = account_to
    @amount = amount
    validate!
    @transfer_class = determine_transfer_class
    @full_iterations = calculate_full_iterations
    @transfers = []
  end

  def execute_transfer!
    validate_withdraw_balance!
    determine_execute_transfer
    @transfers
  end

  def transfer_splitted?
    @amount > @transfer_class.amount_limit
  end

  def full_withdraw_amount
    iterations = @amount + @full_iterations * @transfer_class.commission
    iterations += @transfer_class.commission if last_iteration_amount > '0.0'.to_d
    iterations
  end

  private

  def determine_transfer_class
    if @account_from.bank == @account_to.bank
      Banking::Transfers::TransferIntraBank
    else
      Banking::Transfers::TransferInterBank
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
    (@amount / @transfer_class.amount_limit).to_i
  end

  def last_iteration_amount
    @amount % @transfer_class.amount_limit
  end

  def execute_splitted_transfer
    @full_iterations.times { |_i| execute_individual_transfer(@transfer_class.amount_limit) }
    execute_individual_transfer(last_iteration_amount) unless last_iteration_amount.zero?
  end

  def execute_individual_transfer(amount)
    transfer = @transfer_class.new(@account_from, @account_to, amount)
    transfer.apply until transfer.succeeded?
    @transfers << transfer
  end

  def validate!
    validate_account!(@account_from)
    validate_account!(@account_to)
    raise ArgumentError, 'amount of money must be positive' if @amount < '0'.to_d
  end

  def validate_withdraw_balance!
    raise StandardError, 'account balance not enough for transfer' if @account_from.balance < full_withdraw_amount
  end
end
