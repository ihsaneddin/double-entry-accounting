class CreateAccountingAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounting_accounts do |t|
      t.string :name
      t.string :type
      t.string :code, unique: true, null: false
      t.boolean :contra, default: false
      t.boolean :normal_credit_balance, default: true
      t.references :tenant, polymorphic: true
      t.timestamps
    end
    add_index :accounting_accounts, [:name, :type]
    add_index :accounting_accounts, [:tenant_id, :tenant_type]
  end
end
