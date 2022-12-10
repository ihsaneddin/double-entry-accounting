module Accounting
  module Accounts
    class Asset < ::Accounting::Account

      # self.normal_credit_balance = false

      before_validation do
        self.normal_credit_balance= false #self.class.normal_credit_balance
      end

      def balance(options={})
        super(options)
      end

      def self.balance(options={})
        super(options)
      end

    end
  end
end