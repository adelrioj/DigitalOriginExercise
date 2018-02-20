module Banking
  # Bank represents an entity that holds the list of Accounts and Transactions
  class Bank

    attr_reader :name

    def initialize(name)
      @name = name
      @accounts = {}
      validate!
    end

    def add_account(account_id, account)
      @accounts[account_id] = account
    end

    def find_account(account_id)
      @accounts[account_id]
    end

    def ==(other)
      @name == other.name
    end

    private

    def validate!
      raise ArgumentError, 'Empty name' if @name.nil?
      raise ArgumentError, 'Name must be a symbol' unless @name.is_a?(Symbol)
    end
  end
end
