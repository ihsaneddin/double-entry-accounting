module Accounting
  class Entry < ApplicationRecord

    belongs_to :document, :polymorphic => true, optional: true
    accepts_nested_attributes_for :document
    belongs_to :entity, :polymorphic => true, optional: true
    has_many :credit_amounts, :extend => Extensions::Amounts, :class_name => 'Accounting::Amounts::Credit', :inverse_of => :entry
    has_many :debit_amounts, :extend => Extensions::Amounts, :class_name => 'Accounting::Amounts::Debit', :inverse_of => :entry
    has_many :credit_accounts, :through => :credit_amounts, :source => :account, :class_name => 'Accounting::Account'
    has_many :debit_accounts, :through => :debit_amounts, :source => :account, :class_name => 'Accounting::Account'

    accepts_nested_attributes_for :credit_amounts, allow_destroy: true
    accepts_nested_attributes_for :debit_amounts, allow_destroy: true
    alias_method :credits=, :credit_amounts_attributes=
    alias_method :debits=, :debit_amounts_attributes=
    alias_method :credits, :credit_amounts
    alias_method :debits, :debit_amounts
    alias_method :credits_attributes=, :credit_amounts_attributes=
    alias_method :debits_attributes=, :debit_amounts_attributes=

    attr_accessor :tenant, :tenant_id

    def tenant_id= val
      if ::Accounting.tenant_class
        tenant = ::Accounting.tenant_class.find_by_id(val)
        self.tenant = tenant
      end
      super
    end

    # validates_presence_of :description
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
        errors.add(:credits, :debit_is_required, message: I18n.t("accounting.validation.messages.credit_is_required")) if self.credit_amounts.blank?
      end

      def has_debit_amounts?
        errors.add(:debits, :debit_is_required, message: I18n.t("accounting.validation.messages.debit_is_required")) if self.debit_amounts.blank?
      end

      def amounts_cancel?
        if credit_amounts.balance_for_new_record != debit_amounts.balance_for_new_record
          errors.add(:debits, :invalid_debit_and_credit_amounts, message: I18n.t("accounting.validation.messages.invalid_debit_and_credit_amounts"))
          errors.add(:credits, :invalid_debit_and_credit_amounts, message: I18n.t("accounting.validation.messages.invalid_debit_and_credit_amounts"))
        end
      end

  end
end
