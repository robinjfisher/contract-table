class CreateExtractions < ActiveRecord::Migration[8.1]
  def change
    create_table :extractions do |t|
      t.references :contract, null: false, foreign_key: true
      t.references :field, null: false, foreign_key: true
      t.text :value
      t.text :source_text
      t.integer :source_page
      t.boolean :manually_edited

      t.timestamps
    end
  end
end
