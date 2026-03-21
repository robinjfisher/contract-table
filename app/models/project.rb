class Project < ApplicationRecord
  has_many :contracts, dependent: :destroy
  has_many :fields, -> { order(:position) }, dependent: :destroy

  validates :name, presence: true
end
