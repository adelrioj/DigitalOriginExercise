module Banking
  module Transfers
    # contains methods that could be used across different kinds of transfers
    module TransferHelper

      STATUS_SUCCESS = 'success'.freeze
      STATUS_FAIL = 'fail'.freeze

      def validate_account(account)
        raise ArgumentError, 'You must use a valid Account to operate' unless account.respond_to?('deposit')
        raise ArgumentError, 'You must use a valid Account to operate' unless account.respond_to?('withdraw')
      end

      def pretiffy_amount(amount)
        (amount.to_f * 100).to_i / 100.0
      end
    end
  end
end
