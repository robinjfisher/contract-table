class AddRiskStatusToContracts < ActiveRecord::Migration[8.1]
  def change
    add_column :contracts, :risk_status, :string
  end
end
