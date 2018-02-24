module Banking
  # contains some utils to work with money
  module MoneyHelper
    def prettify(amount)
      (amount.to_f * 100).to_i / 100.0
    end
  end
end