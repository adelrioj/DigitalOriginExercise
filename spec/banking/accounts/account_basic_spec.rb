require 'spec_helper'

RSpec.describe Banking::Accounts::AccountBasic do

  INITIAL_DEPOSIT = '1000'.to_d.freeze
  CLIENT_NAME = 'client'.freeze

  let(:account) { Banking::Accounts::AccountBasic.new(CLIENT_NAME, INITIAL_DEPOSIT) }

  describe 'create account' do
    it 'has a client_name' do
      expect(account.client_name).to eq(CLIENT_NAME)
    end

    it 'has an account number' do
      expect(account.account_number).not_to be_nil
    end

    it 'has a balace equal to the amount deposited as initial_deposit' do
      expect(account.balance).to eq(INITIAL_DEPOSIT)
    end

    it 'has a default value for initial_deposit' do
      default_deposit_account = Banking::Accounts::AccountBasic.new(CLIENT_NAME)
      expect(default_deposit_account.balance).to eq(Banking::Accounts::AccountBasic::DEFAULT_INITIAL_DEPOSIT)
    end
  end

  describe 'deposit in account' do
    it 'deposit defined amount' do
      amount = '1000'.to_d
      total_amount = amount + INITIAL_DEPOSIT
      expect(account.deposit(amount)).to eq(total_amount)
    end
  end

  describe 'withdraw from account' do
    it 'deposit defined amount' do
      amount = '500'.to_d
      total_amount = INITIAL_DEPOSIT - amount
      expect(account.withdraw(amount)).to eq(total_amount)
    end
  end

  describe 'errors' do
    it 'Account has empty client_name' do
      expect { Banking::Accounts::AccountBasic.new('') }
        .to raise_error('Empty client_name')
    end

    it 'Account initial_deposit is not BigDecimal' do
      expect { Banking::Accounts::AccountBasic.new('test_client', 5) }
        .to raise_error('initial_deposit must be BigDecimal')
    end

    it 'Account with negative initial deposit' do
      expect { Banking::Accounts::AccountBasic.new('test_client', '-5.0'.to_d) }
        .to raise_error('amount of money must be positive')
    end

    it 'deposit negative amount' do
      expect { account.deposit('-5.0'.to_d) }.to raise_error('amount of money must be positive')
    end

    it 'withdraw negative amount' do
      expect { account.withdraw('-5.0'.to_d) }.to raise_error('amount of money must be positive')
    end

    it 'withdraw more than in balance' do
      expect { account.withdraw(account.balance + '1.0'.to_d) }
        .to raise_error('Not enough money on the account for the requested withdraw')
    end
  end
end