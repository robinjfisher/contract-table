class Contract < ApplicationRecord
  RISK_STATUSES = %w[clear caution alert].freeze

  belongs_to :project
  has_many :extractions, dependent: :destroy
  has_one_attached :file

  enum :status, { pending: 0, processing: 1, done: 2, error: 3 }

  validates :name, presence: true
  validates :status, presence: true
  validates :risk_status, inclusion: { in: RISK_STATUSES }, allow_nil: true
end
