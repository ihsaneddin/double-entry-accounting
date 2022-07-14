class CreateAccountingAmounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounting_amounts do |t|
      t.string :type
      t.references :account
      t.references :entry
      t.decimal :amount, :precision => 20, :scale => 10
      t.timestamps
    end
  end
end
