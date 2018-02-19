module Banking
  module Accounts

    module AccountHelper
      def create_account_number
        rand(10**10)
      end
    end
  end
end