require 'spec_helper'

RSpec.describe Banking::Transfers::TransferIntraBank do

  AMOUNT = '1000'.to_d.freeze

  let(:bank) { Banking::Bank.new(:test_bank) }
  let(:from) { Banking::Accounts::AccountBasic.new(bank, 'client', AMOUNT) }
  let(:to) { Banking::Accounts::AccountBasic.new(bank, 'client', AMOUNT) }
  let(:transfer) { Banking::Transfers::TransferIntraBank.new(from, to, AMOUNT) }

  describe 'create Transfer' do
    it 'has origin account' do
      expect(transfer.account_from).to eq(from)
    end

    it 'has destination account' do
      expect(transfer.account_to).to eq(to)
    end

    it 'has amount to transfer' do
      expect(transfer.amount).to eq(AMOUNT)
    end

    it 'amount <= limit' do
      limit = Banking::Transfers::TransferInterBank.amount_limit
      expect(transfer.amount).to be <= limit
    end
  end

  describe 'apply transfer' do
    it 'applies correctly' do
      balance_from_before = from.balance
      balance_to_before = to.balance
      transfer.apply
      expect(transfer.succeeded?).to be true
      net_withdraw_amount = transfer.amount + Banking::Transfers::TransferIntraBank.commission
      expect(from.balance).to eq(balance_from_before - net_withdraw_amount)
      expect(to.balance).to eq(balance_to_before + transfer.amount)
    end

    it 'gets stored in Bank' do
      size_transfers_bank_before = bank.transfers.size
      transfer.apply
      expect(bank.transfers.size).to eq(size_transfers_bank_before + 1)
    end
  end

  describe 'errors' do
    it 'transfer has negative amount' do
      expect { Banking::Transfers::TransferIntraBank.new(from, to, '-5.0'.to_d) }
        .to raise_error('amount of money must be positive')
    end

    it 'accounts are the same' do
      expect { Banking::Transfers::TransferIntraBank.new(from, from, AMOUNT) }
        .to raise_error('Accounts must be different')
    end
  end
end