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

  attr_reader :account

  def initialize(account)
    @account = account
    validate!
  end

  def execute_transfer!(account_to, amount)
    transfer = determine_transfer(account_to, amount)
    raise ArgumentError, 'amount of money must be <= amount_limit' if amount > transfer.amount_limit
    transfer.apply until transfer.succeeded?
    transfer
  end

  private

  def validate!
    validate_account!(account)
  end

  def determine_transfer(account_to, amount)
    if @account.bank == account_to.bank
      Banking::Transfers::TransferIntraBank.new(@account, account_to, amount)
    else
      Banking::Transfers::TransferInterBank.new(@account, account_to, amount)
    end
  end
end
