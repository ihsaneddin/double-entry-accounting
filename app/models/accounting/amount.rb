module Accounting
  class Amount < ApplicationRecord

    belongs_to :entry, :class_name => 'Accounting::Entry', foreign_key: :entry_id
    belongs_to :account, :class_name => 'Accounting::Account'

    validates_presence_of :type, :amount, :entry, :account

    delegate :name, :code, to: :account, prefix: true, allow_nil: true

    attr_accessor :account_type

    def account_name=(name)
      tenant = entry.try :tenant
      if ::Accounting.enable_dynamic_account_name
        self.account = get_account_type_class(account_type).find_or_create_by(name: name, tenant: tenant)
      else
        self.account = get_account_type_class(account_type).find_by!(name: name, tenant: tenant)
      end
    end

    def account_code=(code)
      tenant = entry.try :tenant
      self.account = get_account_type_class(account_type).find_by!(code: code, tenant: tenant)
    end

    private

      def get_account_type_class account_type=nil
        case account_type
        when "asset"
          ::Accounting::Accounts::Asset
        when "equity"
          ::Accounting::Accounts::Equity
        when "expense"
          ::Accounting::Accounts::Expense
        when "liability"
          ::Accounting::Accounts::Liability
        when "revenue"
          ::Accounting::Accounts::Revenue
        else
          ::Accounting::Account
        end
      end

  end
end
