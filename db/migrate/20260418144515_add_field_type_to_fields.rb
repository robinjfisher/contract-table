class AddFieldTypeToFields < ActiveRecord::Migration[8.1]
  def change
    add_column :fields, :field_type, :string, default: "text", null: false
  end
end
