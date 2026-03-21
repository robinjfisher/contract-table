class CreateContracts < ActiveRecord::Migration[8.1]
  def change
    create_table :contracts do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name
      t.integer :status

      t.timestamps
    end
  end
end
