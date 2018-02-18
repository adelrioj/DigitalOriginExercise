require "spec_helper"

RSpec.describe Banking::Bank do
  describe 'create bank' do
    it 'has a name' do
      expect(Banking::Bank.new(:test_bank).name).to eq(:test_bank)
    end
  end

  describe 'errors' do
    it 'Bank has nil name' do
      expect { Banking::Bank.new(nil) }.to raise_error('Empty name')
    end

    it 'Bank name is not a symbol' do
      expect { Banking::Bank.new('wrong name') }.to raise_error('Name must be a symbol')
    end
  end
end