BANKING
======

_A code challenge for Digital Origin by Alejandro del Rio Juango_ 

This solution use a gem structure.
I developed it using RVM as a version manager, so the project includes .ruby-gemset and .ruby-version files.

In the following points, I will explain some decisions that I made to solve this challenge:

 - TransferAgent is account-agnostic and it's really easy to add new transfer types to it.
 - Transfers are easy to add as well, because they are created by type instead of an ad-hoc solution. 
 They are adjusted to what is described in the challenge. In order to add more Transfers, just create transfers with different
 parameters and initialize TransferAgent with it.
 - To allow the TransferAgent to use new transfer types, just add the new class to 
 TransferAgent::determine_transfer_class method.
 
 You can install the gem and run the example or you can run the suite of tests to check the results or both, it's up to you.
 
## Questions:
 - How would you improve your solution?
The solution has some issues and posibilities to improve:
    - Account numbers are not unique. When creating an account number, the system should be aware of which numbers are available.
    - TransferAgent uses accounts of different banks as if they are fully available. Probably, a good addition would be 
    to manage accounts different depending on each bank specifications.
    - show_me_the_money does too much stuff. A better approach would be to create a notifier class, some kind of 
    observer over TransferAgent, that shows the before and after status of the operation.
 
 - How would you adapt your solution if transfers are not instantaneous?
    - First of all, accounts should have some 'balance-buffer' to manage that some cash that must be transfered 
    is still in the account but is not available.
    - TransferAgent should be modified to know how to deal with the delay. Right now every Transfer::apply is made
    synchronously and probably it should be re-write to be asynchronous.
    - Transfers should have a new state: requested, to represent that the Transfer has been applied, but it is still
    being processed.

## Setting up

> gem install bundler
> bundle install

## Testing

> bundle exec rspec spec

## Build gem

> gem build banking.gemspec

## Run show_me_the_money script:
> gem install ./banking-0.1.0.gem 
> ruby show_me_the_money.rb 