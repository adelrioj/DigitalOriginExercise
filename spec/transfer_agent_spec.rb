require "spec_helper"

RSpec.describe TransferAgent do

  TRANSFER_TYPES = {
    intra_bank: Banking::Transfers::TransferBasic.new('+Infinity'.to_d, '0.0'.to_d, 0),
    inter_bank: Banking::Transfers::TransferBasic.new('1000.0'.to_d, '5.0'.to_d, 30)
  }.freeze

  let(:account_amount) { '100000'.to_d }
  let(:transfer_amount) { '2000'.to_d }

  let(:bank_a) { Banking::Bank.new(:A) }
  let(:bank_b) { Banking::Bank.new(:B) }

  let(:account_from_a) { Banking::Accounts::AccountBasic.new(bank_a, 'client', account_amount) }
  let(:account_to_a) { Banking::Accounts::AccountBasic.new(bank_a, 'client', account_amount) }
  let(:account_to_b) { Banking::Accounts::AccountBasic.new(bank_b, 'client', account_amount) }

  let(:transfer_agent) { TransferAgent.new(TRANSFER_TYPES) }

  describe 'create agent' do
    it 'has transfer types' do
      expect(transfer_agent.transfer_types).not_to be_empty
    end
  end

  describe 'examples of use' do
    it 'scenario intra-bank' do
      balance_from_before = account_from_a.balance
      balance_to_before = account_to_a.balance
      expect(transfer_agent.execute_transfer(account_from_a, account_to_a, transfer_amount).size).to be(1)
      expect(account_from_a.balance).to eq(balance_from_before - transfer_agent.full_withdraw_amount)
      expect(account_to_a.balance).to eq(balance_to_before + transfer_amount)
    end

    it 'scenario inter-bank' do
      balance_from_before = account_from_a.balance
      balance_to_before = account_to_b.balance
      expect(transfer_agent.execute_transfer(account_from_a, account_to_b, transfer_amount).size).to be > 1
      expect(account_from_a.balance).to eq(balance_from_before - transfer_agent.full_withdraw_amount)
      expect(account_to_b.balance).to eq(balance_to_before + transfer_amount)
    end

    it 'stores in bank correctly' do
      bank_transfers_size_from = bank_a.transfers.size
      bank_transfers_size_to = bank_b.transfers.size
      records = transfer_agent.execute_transfer(account_from_a, account_to_b, transfer_amount)
      expect(bank_a.transfers.size).to eq(bank_transfers_size_from + records.size)
      expect(bank_b.transfers.size).to eq(bank_transfers_size_to + records.size)
    end
  end

  describe 'errors' do
    it 'negative amount' do
      expect { transfer_agent.execute_transfer(account_from_a, account_to_b, '-5.0'.to_d) }
        .to raise_error('amount of money must be positive')
    end

    it 'not enough balance in origin' do
      expect { transfer_agent.execute_transfer(account_from_a, account_to_b, account_from_a.balance + '1.0'.to_d) }
        .to raise_error('not enough account balance for transfer')
    end
  end
end