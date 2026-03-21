class Extraction < ApplicationRecord
  belongs_to :contract
  belongs_to :field

  validates :contract, uniqueness: { scope: :field_id }
end
