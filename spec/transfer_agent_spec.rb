require "spec_helper"

RSpec.describe TransferAgent do

  let(:account_amount) { '100000'.to_d }
  let(:transfer_amount) { '2000'.to_d }

  let(:bank_a) { Banking::Bank.new(:A) }
  let(:bank_b) { Banking::Bank.new(:B) }

  let(:account_from_a) { Banking::Accounts::AccountBasic.new(bank_a, 'client', account_amount) }
  let(:account_to_a) { Banking::Accounts::AccountBasic.new(bank_a, 'client', account_amount) }
  let(:account_to_b) { Banking::Accounts::AccountBasic.new(bank_b, 'client', account_amount) }

  let(:transfer_agent) { TransferAgent.new(account_from_a, account_to_b, transfer_amount) }

  describe 'create agent' do
    it 'has an origin account' do
      expect(transfer_agent.account_from).to eq(account_from_a)
    end
    it 'has a destination account' do
      expect(transfer_agent.account_to).to eq(account_to_b)
    end
    it 'has amount' do
      expect(transfer_agent.amount).to eq(transfer_amount)
    end
  end

  describe 'execute transfer' do
    it 'executes correctly intra-bank' do
      balance_from_before = account_from_a.balance
      balance_to_before = account_to_a.balance
      agent = TransferAgent.new(account_from_a, account_to_a, transfer_amount)
      expect(agent.transfer_splitted?).to be false
      expect(agent.execute_transfer.size).to be(1)
      expect(account_from_a.balance).to eq(balance_from_before - agent.full_withdraw_amount)
      expect(account_to_a.balance).to eq(balance_to_before + agent.amount)
    end

    it 'executes correctly inter-bank' do
      balance_from_before = account_from_a.balance
      balance_to_before = account_to_b.balance
      agent = TransferAgent.new(account_from_a, account_to_b, transfer_amount)
      expect(agent.transfer_splitted?).to be true
      expect(agent.execute_transfer.size).to be > 1
      expect(account_from_a.balance).to eq(balance_from_before - agent.full_withdraw_amount)
      expect(account_to_b.balance).to eq(balance_to_before + agent.amount)
    end

    it 'stores in bank correctly' do
      bank_transfers_size_from = bank_a.transfers.size
      bank_transfers_size_to = bank_b.transfers.size
      transfer_agent.execute_transfer
      expect(bank_a.transfers.size).to eq(bank_transfers_size_from + transfer_agent.transfers.size)
      expect(bank_b.transfers.size).to eq(bank_transfers_size_to + transfer_agent.transfers.size)
    end
  end

  describe 'errors' do
    it 'uses non valid account_from for transfer at creation' do
      expect { TransferAgent.new('fake_account', account_to_a, transfer_amount) }
        .to raise_error('You must use a valid Account to operate')
      expect { TransferAgent.new(account_from_a, 'fake_account', transfer_amount) }
        .to raise_error('You must use a valid Account to operate')
    end

    it 'negative amount' do
      expect { TransferAgent.new(account_from_a, account_to_b, '-5.0'.to_d) }
        .to raise_error('amount of money must be positive')
    end

    it 'not enough balance in origin' do
      agent = TransferAgent.new(account_from_a, account_to_b, account_from_a.balance + '1.0'.to_d)
      expect { agent.execute_transfer }
        .to raise_error('account balance not enough for transfer')
    end
  end
end