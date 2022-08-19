
require 'accounting/book_keeping'
require 'rails'

module Accounting
  class Railtie < Rails::Railtie
    initializer 'accounting.initialize' do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.send :include, Accounting::BookKeeping
      end
    end
  end
end