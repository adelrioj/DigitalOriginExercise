require "spec_helper"

RSpec.describe TransferAgent do

  ACCOUNT_AMOUNT = '1000'.to_d.freeze
  TRANSFER_AMOUNT = '500'.to_d.freeze

  let(:bank_from) { Banking::Bank.new(:test_bank_from) }
  let(:bank_to) { Banking::Bank.new(:test_bank_to) }
  let(:account_from) { Banking::Accounts::AccountBasic.new(bank_from, 'client', ACCOUNT_AMOUNT) }
  let(:account_to) { Banking::Accounts::AccountBasic.new(bank_to, 'client', ACCOUNT_AMOUNT) }
  let(:transfer_agent) { TransferAgent.new(account_from) }

  describe 'create agent' do
    it 'has a transfer' do
      expect(transfer_agent.account).not_to be_nil
      expect(transfer_agent.account).to eq(account_from)
    end
  end

  describe 'execute transfer' do
    it 'executes correctly' do
      expect(transfer_agent.execute_transfer!(account_to, TRANSFER_AMOUNT).succeeded?)
        .to be true
    end

    it 'stores in bank correctly' do
      bank_transfers_size_from = bank_from.transfers.size
      bank_transfers_size_to = bank_to.transfers.size
      transfer_agent.execute_transfer!(account_to, TRANSFER_AMOUNT)
      expect(bank_from.transfers.size).to eq(bank_transfers_size_from + 1)
      expect(bank_to.transfers.size).to eq(bank_transfers_size_to + 1)
    end
  end

  describe 'errors' do
    it 'uses non valid account for transfer at creation' do
      expect { TransferAgent.new('fake_account') }
        .to raise_error('You must use a valid Account to operate')
    end
  end
end