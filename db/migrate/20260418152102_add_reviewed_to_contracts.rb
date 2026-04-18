class AddReviewedToContracts < ActiveRecord::Migration[8.1]
  def change
    add_column :contracts, :reviewed, :boolean, default: false, null: false
    add_column :contracts, :reviewed_at, :datetime
  end
end
