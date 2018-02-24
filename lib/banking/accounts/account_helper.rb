module Banking
  module Accounts
    # contains methods that could be used across different kinds of accounts
    module AccountHelper
      def create_account_number
        rand(10**10)
      end
    end
  end
end