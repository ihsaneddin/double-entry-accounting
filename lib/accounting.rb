require 'sidekiq'
require "accounting/engine"
require "accounting/book_keeping"

module Accounting

  mattr_accessor :enable_tenancy
  enable_tenancy = false

  mattr_accessor :tenant_class
  tenant_class = nil

  mattr_accessor :enable_dynamic_account_name
  enable_dynamic_account_name = false

  mattr_accessor :enable_asynchronous_balance_insertion
  mattr_accessor :enable_asynchronous_balance_insertion_queue

  enable_asynchronous_balance_insertion = false
  enable_asynchronous_balance_insertion_queue = :default

  def self.config
    yield(self)
  end

  def entry tenant: nil, account_type: nil, attrs: {}
    entry = Accounting::Entry.new({tenant: tenant, account_type: account_type}.merge(attrs))
    entry.save
    entry
  end

end


require 'accounting/railtie'