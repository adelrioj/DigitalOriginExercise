# Jim has an account on the bank A and Emma has an account on the bank B.
# Jim owes Emma 20000€.
# Emma is already a bit angry, because she did not get the money although Jim told her that he already sent it.
#
# Help Jim send his money by developing a  transfer agent .
# This agent assures that everybody gets their money.
# When the agent receives an order to transfer money from account A to account B,
# he issues transfers considering commissions, transfer limits and possibility of transfer failures.
#
# The execution of the script will print the balance of every account before and after the transfers
# and the history of the transfer of every bank.

require 'transfer_agent'

def call_agent(account_jim, account_emma, jim_debt)
  TransferAgent.new(account_jim, account_emma, jim_debt).execute_transfer
  puts 'Agent operation is finished'
rescue ArgumentError => e
  puts "Agent reports an error: #{e.message}"
end

def print_status(account_a, account_b)
  print_account_status(account_a)
  puts ' '
  print_account_status(account_b)
  puts ' '
end

def print_account_status(account)
  pretty_balance = (account.balance.to_f * 100).to_i / 100.0
  puts "#{account.client_name}'s account balance is #{pretty_balance}€"
  print_bank_transfers(account.bank)
end

def print_bank_transfers(bank)
  puts "Bank #{bank.name} transfer history is:"
  if bank.transfers.empty?
    puts 'Empty'
  else
    bank.transfers.each do |transfer|
      puts "Transfer: #{transfer}"
    end
  end
end

bank_a = Banking::Bank.new(:A)
bank_b = Banking::Bank.new(:B)

account_jim = Banking::Accounts::AccountBasic.new(bank_a, 'Jim', '25000'.to_d)
account_emma = Banking::Accounts::AccountBasic.new(bank_b, 'Emma', '25000'.to_d)

jim_debt = '20000'.to_d

puts 'BEFORE the operation:'
print_status(account_jim, account_emma)

puts 'Jim calls his agent to execute transfer'
call_agent(account_jim, account_emma, jim_debt)

puts 'AFTER the operation:'
print_status(account_jim, account_emma)