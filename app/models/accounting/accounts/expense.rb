module Accounting
  module Accounts
    class Expense < ::Accounting::Account

      self.normal_credit_balance = false

      before_validation do
        self.normal_credit_balance= self.class.normal_credit_balance
      end

      def balance(options={})
        super
      end

      def self.balance(options={})
        super
      end

    end
  end
end