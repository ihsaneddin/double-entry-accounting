module Accounting
  module Accounts
    class Expense < ::Accounting::Account

      self.normal_credit_balance = false

      def balance(options={})
        super
      end

      def self.balance(options={})
        super
      end

    end
  end
end