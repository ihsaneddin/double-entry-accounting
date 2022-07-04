class CreateAccountingTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :accounting_transactions do |t|
      t.string :description
      t.date :date
      t.references :document, polymorphic: true
      t.boolean :reconciliation, default: nil
      t.timestamps
    end
    add_index :accounting_transactions, :date
    add_index :accounting_transactions, [:document_id, :document_type], :name => "index_transactions_on_document"

  end
end
