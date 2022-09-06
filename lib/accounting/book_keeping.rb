require_relative "./book_keeping_config"

module Accounting
  module BookKeeping
    extend ActiveSupport::Concern

    module ClassMethods

      def acts_as_accountable
        unless include?(Helpers)
          include Helpers
        end
      end

    end

    module Helpers
      extend ActiveSupport::Concern

      included do
        class_attribute :book_keeping_configs
        self.book_keeping_configs = {}
        insert_entry
      end

      def accounting_entry &block
        raise "Need block!" unless block_given?
        config = Accounting::BookKeepingConfig.build_config &block
        self.book_keeping_configs[self.name] ||= []
        self.book_keeping_configs[self.name] << config
      end

      protected

      def insert_entries callback
        current_book_keeping_configs.each do |cfg|
          cfg.insert_entry(self, callback)
        end
      end

      module ClassMethods
        
        def insert_entries
          [:after_create, :after_update, :after_destroy].each do |callback|
            send(callback) do 
              insert_entries(callback)
            end 
          end
        end

        def current_book_keeping_configs
          self.book_keeping_configs[self.name] || []
        end
      
      end

    end

  end
end
