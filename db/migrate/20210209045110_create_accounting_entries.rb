class CreateAccountingEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :accounting_entries do |t|
      t.string :description
      t.date :date
      t.references :document, polymorphic: true
      t.boolean :reconciliation, default: nil
      t.timestamps
    end
    add_index :accounting_entries, :date
    add_index :accounting_entries, [:document_id, :document_type], :name => "index_entries_on_document"

  end
end
