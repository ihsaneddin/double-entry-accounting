module Accounting
  module Extensions
    module Amounts

      def balance(from: nil, to: nil)
        if from && to
          from_date = from.kind_of?(Date) ? from : Date.parse(from)
          to_date = to.kind_of?(Date) ? to : Date.parse(to)
          includes(:entry).where('accounting_entries.date' => from_date..to_date).sum(:amount)
        elsif from && to.nil?
          from_date = from.kind_of?(Date) ? from : Date.parse(from)
          includes(:entry).where('accounting_entries.date >=', from_date).sum(:amount)
        elsif from.nil? && to
          to_date = to.kind_of?(Date) ? to : Date.parse(to)
          includes(:entry).where('accounting_entries.date <=', to_date).sum(:amount)
        else
          sum(:amount)
        end
      end

      def balance_for_new_record
        balance = BigDecimal('0')
        each do |amount_record|
          if amount_record.amount && !amount_record.marked_for_destruction?
            balance += amount_record.amount # unless amount_record.marked_for_destruction?
          end
        end
        return balance
      end
    end
  end
end
