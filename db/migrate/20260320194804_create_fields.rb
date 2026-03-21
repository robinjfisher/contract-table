class CreateFields < ActiveRecord::Migration[8.1]
  def change
    create_table :fields do |t|
      t.references :project, null: false, foreign_key: true
      t.string :label
      t.string :question
      t.string :predefined_key
      t.integer :position

      t.timestamps
    end
  end
end
