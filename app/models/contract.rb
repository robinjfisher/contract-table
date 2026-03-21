class Contract < ApplicationRecord
  belongs_to :project
  has_many :extractions, dependent: :destroy
  has_one_attached :file

  enum :status, { pending: 0, processing: 1, done: 2, error: 3 }

  validates :name, presence: true
  validates :status, presence: true
end
