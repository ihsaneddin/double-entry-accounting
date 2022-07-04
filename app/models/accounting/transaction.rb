module Accounting
  class Transaction < ApplicationRecord

    belongs_to :document, :polymorphic => true, optional: true
    belongs_to :entity, :polymorphic => true, optional: true
    has_many :credit_amounts, :extend => Extensions::Amounts, :class_name => 'Accounting::Amounts::Credit', :inverse_of => :entry
    has_many :debit_amounts, :extend => Extensions::Amounts, :class_name => 'Accounting::Amounts::Debit', :inverse_of => :entry
    has_many :credit_accounts, :through => :credit_amounts, :source => :account, :class_name => 'Accounting::Account'
    has_many :debit_accounts, :through => :debit_amounts, :source => :account, :class_name => 'Accounting::Account'

    accepts_nested_attributes_for :credit_amounts, :debit_amounts, allow_destroy: true
    alias_method :credits=, :credit_amounts_attributes=
    alias_method :debits=, :debit_amounts_attributes=

    attr_accessor :tenant, :tenant_id

    def tenant_id= val
      if ::Accounting.tenant_class
        tenant = ::Accounting.tenant_class.find_by_id(val)
        self.tenant = tenant
      end
      super
    end

    validates_presence_of :description
    validate :has_credit_amounts?
    validate :has_debit_amounts?
    validate :amounts_cancel?

    before_save :default_date

    private

      def default_date
        todays_date = ApplicationRecord.default_timezone == :utc ? Time.now.utc : Time.now
        self.date ||= todays_date
      end

      def has_credit_amounts?
        errors[:base] << "Entry must have at least one credit amount" if self.credit_amounts.blank?
      end

      def has_debit_amounts?
        errors[:base] << "Entry must have at least one debit amount" if self.debit_amounts.blank?
      end

      def amounts_cancel?
        errors[:base] << "The credit and debit amounts are not equal" if credit_amounts.balance_for_new_record != debit_amounts.balance_for_new_record
      end

  end
end
