require 'spec_helper'

RSpec.describe Banking::Transfers::TransferInterBank do

  ACCOUNT_AMOUNT = '1000'.to_d.freeze
  TRANSFER_AMOUNT = '500'.to_d.freeze

  let(:bank_from) { Banking::Bank.new(:test_bank_from) }
  let(:bank_to) { Banking::Bank.new(:test_bank_to) }
  let(:account_from) { Banking::Accounts::AccountBasic.new(bank_from, 'client', ACCOUNT_AMOUNT) }
  let(:account_to) { Banking::Accounts::AccountBasic.new(bank_to, 'client', ACCOUNT_AMOUNT) }
  let(:transfer) { Banking::Transfers::TransferInterBank.new(account_from, account_to, TRANSFER_AMOUNT) }


  describe 'create Transfer' do
    it 'has origin account' do
      expect(transfer.account_from).not_to be_nil
      expect(transfer.account_from).to eq(account_from)
    end

    it 'has destination account' do
      expect(transfer.account_to).not_to be_nil
      expect(transfer.account_to).to eq(account_to)
    end

    it 'has amount to transfer' do
      expect(transfer.amount).to eq(TRANSFER_AMOUNT)
    end

    it 'amount <= limit' do
      expect(transfer.amount).to be <= transfer.amount_limit
    end
  end

  describe 'apply transfer' do
    before do
      # ensures that transfer always succeed
      expect(transfer).to receive(:attempt_succeeded?).and_return(true)
    end

    it 'applies correctly' do
      balance_from_before = account_from.balance
      balance_to_before = account_to.balance
      transfer.apply
      expect(transfer.succeeded?).to be true
      expect(account_from.balance).to eq(balance_from_before - transfer.total_amount)
      expect(account_to.balance).to eq(balance_to_before + transfer.amount)
    end

    it 'gets stored in Bank' do
      size_transfers_before_from = bank_from.transfers.size
      size_transfers_after_to = bank_to.transfers.size
      transfer.apply
      expect(bank_from.transfers.size).to eq(size_transfers_before_from + 1)
      expect(bank_to.transfers.size).to eq(size_transfers_after_to + 1)
    end
  end

  describe 'errors' do
    it 'transfer has negative amount' do
      expect { Banking::Transfers::TransferInterBank.new(account_from, account_to, '-5.0'.to_d) }
          .to raise_error('amount of money must be positive')
    end

    it 'amount is above limit' do
      expect { Banking::Transfers::TransferInterBank.new(account_from, account_to, '1001.0'.to_d) }
          .to raise_error('amount of money must be <= amount_limit')
    end

    it 'accounts are the same' do
      expect { Banking::Transfers::TransferInterBank.new(account_from, account_from, ACCOUNT_AMOUNT) }
          .to raise_error('Accounts must be different')
    end

    it 'accounts are from the same bank' do
      to_same_bank = Banking::Accounts::AccountBasic.new(account_from.bank, 'client', ACCOUNT_AMOUNT)
      expect { Banking::Transfers::TransferInterBank.new(account_from, to_same_bank, ACCOUNT_AMOUNT) }
          .to raise_error('Banks must be different')
    end

    it 'total_amount > origin account balance' do
      fail_transfer = Banking::Transfers::TransferInterBank.new(account_from, account_to, ACCOUNT_AMOUNT)
      expect(fail_transfer).to receive(:attempt_succeeded?).and_return(true)
      expect(fail_transfer.apply.succeeded?).to be false
    end
  end
end