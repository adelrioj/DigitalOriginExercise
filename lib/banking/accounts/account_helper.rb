module Banking
  module Accounts
    # contains methods that could be used across different kinds of accounts
    module AccountHelper
      def create_account_number
        rand(10**10)
      end

      def check_positive_amount(amount)
        raise ArgumentError, 'amount of money must be positive' if amount < '0'.to_d
      end
    end
  end
end