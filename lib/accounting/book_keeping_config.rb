module Accounting
  class BookKeepingConfig
    
    attr_accessor :options, :object

    def self.build_config &block
      config = Accounting::BookKeepingConfig.new({})
      yield(config)
      config
    end

    def initialize params= {}
      self.options = {
        tenant: nil,
        description: "", 
        date: nil, 
        debits: [], 
        credits: [], 
        if: false, 
        when: :after_save, 
        async: ::Accounting.enable_asynchronous_balance_insertion, 
        worker: Accounting::EntryWorker
      }
      self.options.merge! params        
    end
    
    def get_option key
      if object
        opt = options.dig key
        case opt
        when Proc
          opt.call(object, options)
          # object.instance_exec(opt, options)
        when Symbol
          object.send opt
        else
          opt
        end
      end
    end

    def set_option :key, val
      self.options[key] = val
    end

    def entry_description val=nil, &block
      if block_given?
        set_option :description, block
      else
        set_option :description, val
      end
    end

    def entry_date val=nil, &block
      if block_given?
        set_option :date, block
      else
        set_option :date, val
      end
    end

    def entry_tenant val=nil, &block
      if block_given?
        set_option :tenant, block
      else
        set_option :tenant, val
      end
    end

    def entry_credits val=nil, &block
      if block_given?
        set_option :credits, block
      else
        set_option :credits, val
      end
    end

    def entry_debits val=nil, &block
      if block_given?
        set_option :debits, block
      else
        set_option :debits, val
      end
    end

    def should_save_as_async? val=nil, &block
      if block_given?
        set_option :async, block
      else
        set_option :async, val
      end
    end

    def async_worker val=nil, &block
      if block_given?
        set_option :worker, block
      else
        set_option :worker, val
      end
    end

    def insert_entry_if? val=nil, &block
      if block_given?
        set_option :if, block
      else
        set_option :if, val
      end
    end

    def insert_entry_when? val=nil, &block
      if block_given?
        set_option :when, block
      else
        set_option :when, val
      end
    end
    
    def insert_entry! object, when
      if get_option(:when).to.sym == when.to_sym
        if get_option(:if)
          self.object = object
          entry = build_entry
          worker = get_option(:worker)
          if get_option(:async) && worker
            attrs = { description: entry.description, tenant_id: entry.tenant.try(:id), credits: [], debits: [] }
            entry.credits.each do |cr|
              attrs[:credits] << { account_id: cr.account_id, account_type: cr.account_type, amount: cr.amount }
            end
            entry.debits.each do |db|
              attrs[:debits] << { account_id: db.account_id, account_type: db.account_type, amount: db.amount }
            end
            worker.perform_async :action, attrs.to_json
          else
            entry.save
          end
        end
      end
    end

    def worker_class
      worker = get_option :worker
      if(worker)
        worker.is_a?(String) ? worker.constantize : worker rescue nil
      end
    end

    def build_credits
      credits_obj = []
      credits = get_option(:credits)
      credits = Array.new(credits) unless credits.is_a?(Array)
      credits.each do |cr|
        case cr
        when Hash
          credit = ::Accounting::Amounts::Credit.new cr
          credits_obj << credit
        when ::Accounting::Amounts::Credit
          credits_obj << credit
        end
      end
      raise "Credit can't be blank" if credits_obj.blank?
      credits_obj
    end

    def build_debits
      debits_obj = []
      debits = get_option(:debits)
      debits = Array.new(debits) unless debits.is_a?(Array)
      debits.each do |dr|
        case dr
        when Hash
          debit = ::Accounting::Amounts::Debit.new dr
          debits_obj << debit
        when ::Accounting::Amounts::Debit
          debits_obj << dr
        end
      end
      raise "Debit can't be blank" if debits_obj.blank?
      debits_obj
    end

    def build_entry attrs = nil
      attrs ||= { description: get_option(:description), date: get_option(:date), tenant: get_option(:tenant) }
      entry = ::Accounting::Amounts::Entry.new attrs
      build_debits.each {|dr| entry.debit_amounts << dr }
      build_credits.each{|cr| entry.credit_amounts << cr }
    end

  end
end