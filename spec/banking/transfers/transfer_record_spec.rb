require 'spec_helper'

RSpec.describe Banking::Transfers::TransferRecord do

  AMOUNT = '1.0'.to_d.freeze
  COMMISSION = '1.0'.to_d.freeze

  let(:bank) { Banking::Bank.new(:test_bank) }
  let(:account_from) { Banking::Accounts::AccountBasic.new(bank, 'client', AMOUNT) }
  let(:account_to) { Banking::Accounts::AccountBasic.new(bank, 'client', AMOUNT) }

  let(:record) { Banking::Transfers::TransferRecord.new(account_from, account_to, AMOUNT, COMMISSION) }

  describe 'create record' do
    it 'has origin account' do
      expect(record.account_from).to eq(account_from)
    end

    it 'has destination account' do
      expect(record.account_to).to eq(account_to)
    end

    it 'has amount to transfer' do
      expect(record.amount).to eq(AMOUNT)
    end

    it 'has commission' do
      expect(record.commission).to eq(COMMISSION)
    end
  end

  describe 'errors' do
    it 'has negative amount' do
      expect { Banking::Transfers::TransferRecord.new(account_from, account_to, '-5.0'.to_d, COMMISSION) }
        .to raise_error('amount of money must be positive')
    end

    it 'accounts are the same' do
      expect { Banking::Transfers::TransferRecord.new(account_from, account_from, AMOUNT, COMMISSION) }
        .to raise_error('Accounts must be different')
    end
  end
end