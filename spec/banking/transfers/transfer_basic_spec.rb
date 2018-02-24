require 'spec_helper'

RSpec.describe Banking::Transfers::TransferBasic do

  AMOUNT_LIMIT = '1000.0'.to_d.freeze
  COMMISSION = '5.0'.to_d.freeze
  FAILURE_RATIO = 0 # ensures that transfer always succeed
  OPERATION_AMOUNT = '1.0'.to_d.freeze

  let(:bank_a) { Banking::Bank.new(:A) }
  let(:bank_b) { Banking::Bank.new(:B) }
  let(:account_from_a) { Banking::Accounts::AccountBasic.new(bank_a, 'client', '10000.0'.to_d) }
  let(:account_to_a) { Banking::Accounts::AccountBasic.new(bank_a, 'client', '10000.0'.to_d) }
  let(:account_to_b) { Banking::Accounts::AccountBasic.new(bank_b, 'client', '10000.0'.to_d) }
  let(:transfer) { Banking::Transfers::TransferBasic.new(AMOUNT_LIMIT, COMMISSION, FAILURE_RATIO) }

  describe 'create transfer' do
    it 'has commission' do
      expect(transfer.commission).to eq(COMMISSION)
    end
    it 'has amount_limit' do
      expect(transfer.amount_limit).to eq(AMOUNT_LIMIT)
    end
  end

  describe 'apply transfer' do
    it 'applies correctly' do
      balance_from_before = account_from_a.balance
      balance_to_before = account_to_b.balance

      transfer.apply(account_from_a, account_to_b, OPERATION_AMOUNT)

      net_withdraw_amount = OPERATION_AMOUNT + COMMISSION
      expect(account_from_a.balance).to eq(balance_from_before - net_withdraw_amount)
      expect(account_to_b.balance).to eq(balance_to_before + OPERATION_AMOUNT)
    end

    it 'gets stored in Bank - same bank' do
      size_transfers_before_from = account_from_a.bank.transfers.size
      size_transfers_after_to = account_to_a.bank.transfers.size

      transfer.apply(account_from_a, account_to_a, OPERATION_AMOUNT)

      expect(account_from_a.bank.transfers.size).to eq(size_transfers_before_from + 1)
      expect(account_to_a.bank.transfers.size).to eq(size_transfers_after_to + 1)
    end

    it 'gets stored in Bank - different banks' do
      size_transfers_before_from = account_from_a.bank.transfers.size
      size_transfers_after_to = account_to_b.bank.transfers.size

      transfer.apply(account_from_a, account_to_b, OPERATION_AMOUNT)

      expect(account_from_a.bank.transfers.size).to eq(size_transfers_before_from + 1)
      expect(account_to_b.bank.transfers.size).to eq(size_transfers_after_to + 1)
    end
  end

  describe 'errors' do
    it 'amount_limit is not BigDecimal' do
      expect { Banking::Transfers::TransferBasic.new(5, COMMISSION, FAILURE_RATIO) }
        .to raise_error('amount_limit must be BigDecimal')
    end

    it 'negative amount_limit' do
      expect { Banking::Transfers::TransferBasic.new('0.0'.to_d, COMMISSION, FAILURE_RATIO) }
        .to raise_error('amount_limit must be positive')
    end

    it 'commission is not BigDecimal' do
      expect { Banking::Transfers::TransferBasic.new(AMOUNT_LIMIT, 5, FAILURE_RATIO) }
        .to raise_error('commission must be BigDecimal')
    end

    it 'negative commission' do
      expect { Banking::Transfers::TransferBasic.new(AMOUNT_LIMIT, '-1.0'.to_d, FAILURE_RATIO) }
        .to raise_error('commission must be >= 0.0')
    end

    it 'failure_ratio not between 0 and 100' do
      expect { Banking::Transfers::TransferBasic.new(AMOUNT_LIMIT, COMMISSION, -10) }
        .to raise_error('failure_ratio must have a value between 0 and 100')
      expect { Banking::Transfers::TransferBasic.new(AMOUNT_LIMIT, COMMISSION, 101) }
          .to raise_error('failure_ratio must have a value between 0 and 100')
    end

    it 'apply fails due to failure_ratio' do
      expect(transfer).to receive(:attempt_failed?).and_return(true)
      expect { transfer.apply(account_from_a, account_to_a, OPERATION_AMOUNT) }
        .to raise_error('Operation failed!')
    end
  end
end