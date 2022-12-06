module Accounting
  class Account < ApplicationRecord

    class_attribute :normal_credit_balance

    has_many :amounts
    has_many :credit_amounts, :extend => Extensions::Amounts, :class_name => 'Accounting::Amounts::Credit', dependent: :destroy
    has_many :debit_amounts, :extend => Extensions::Amounts, :class_name => 'Accounting::Amounts::Debit', dependent: :destroy
    has_many :entries, through: :amounts, source: :entry, :class_name => 'Accounting::Entry'
    has_many :credit_entries, :through => :credit_amounts, :source => :entry, :class_name => 'Accounting::Entry'
    has_many :debit_entries, :through => :debit_amounts, :source => :entry, :class_name => 'Accounting::Entry'

    if ::Accounting.enable_tenancy
      include ::Accounting::Concerns::Tenancy
    else
      include ::Accounting::Concerns::NoTenancy
    end

    validates_presence_of :type
    validates :name, presence: true
    validates :code, presence: true, uniqueness: { allow_blank: true }

    before_validation do
      self.normal_credit_balance= self.class.normal_credit_balance
    end

    before_validation do
      if name.blank?
        self.name = self.code
      end
      if code.blank?
        self.code = name.to_s + "#{Time.now.to_i}"
      end
    end

    def self.types
      [
        ::Accounting::Accounts::Asset,
        ::Accounting::Accounts::Equity,
        ::Accounting::Accounts::Expense,
        ::Accounting::Accounts::Liability,
        ::Accounting::Accounts::Revenue,
      ]
    end

    def balance(options={})
      if self.class == Accounting::Account
        raise(NoMethodError, "undefined method 'balance'")
      else
        if self.normal_credit_balance ^ contra
          credits_balance(options) - debits_balance(options)
        else
          debits_balance(options) - credits_balance(options)
        end
      end
    end

    def credits_balance(options={})
      credit_amounts.balance(options)
    end

    def debits_balance(options={})
      debit_amounts.balance(options)
    end

    def self.balance(options={})
      if self.new.class == Accounting::Account
        raise(NoMethodError, "undefined method 'balance'")
      else
        accounts_balance = BigDecimal('0')
        accounts = self.all
        accounts.each do |account|
          if account.contra
            accounts_balance -= account.balance(options)
          else
            accounts_balance += account.balance(options)
          end
        end
        accounts_balance
      end
    end

    def self.trial_balance
      if self.new.class == Accounting::Account
        Accounting::Asset.balance - (Accounting::Liability.balance + Accounting::Equity.balance + Accounting::Revenue.balance - Accounting::Expense.balance)
      else
        raise(NoMethodError, "undefined method 'trial_balance'")
      end
    end


  end
end
