require 'json'

module Accounting
  class TransactionWorker

    include ::Sidekiq::Worker
    sidekiq_options :queue => ::Accounting.enable_asynchronous_balance_insertion_queue, :retry => 5, :backtrace => 20

    def perform(action, *args)
      send(action, *args)
    end

    def insertion attrs
      Accounting::Transaction.create JSON.parse(attrs)
    end

  end
end