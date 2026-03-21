class Field < ApplicationRecord
  PREDEFINED_FIELDS = [
    {
      predefined_key: "start_date",
      label: "Start Date",
      question: "What is the effective start date or commencement date of this contract? Return the date only in a readable format, e.g. '1 January 2024'."
    },
    {
      predefined_key: "end_date",
      label: "End Date",
      question: "What is the expiry or end date of this contract? Return the date only, e.g. '31 December 2026', or 'Ongoing' if there is no fixed end date."
    },
    {
      predefined_key: "parties",
      label: "Parties",
      question: "Who are the contracting parties? Return the full legal names only as a comma-separated list, e.g. 'Acme Corp, Widget Ltd'. Do not include addresses or descriptions."
    },
    {
      predefined_key: "contract_value",
      label: "Contract Value",
      question: "What is the total contract value or fee payable? Return a short answer, e.g. '$500,000' or '$10,000/month'. If variable or based on usage, give a brief summary."
    },
    {
      predefined_key: "payment_terms",
      label: "Payment Terms",
      question: "What are the payment terms? Return a short answer, e.g. 'Net 30 days from invoice' or 'Monthly in advance'."
    },
    {
      predefined_key: "governing_law",
      label: "Governing Law",
      question: "What governing law and jurisdiction applies to this contract? Return a short answer, e.g. 'English law' or 'Laws of the State of New York'."
    },
    {
      predefined_key: "notice_period",
      label: "Notice Period",
      question: "What notice period is required to terminate this contract? Return a short answer, e.g. '30 days' or '3 months written notice'."
    },
    {
      predefined_key: "auto_renewal",
      label: "Auto-Renewal",
      question: "Does this contract automatically renew? Answer 'Yes' or 'No'. If yes, briefly state the renewal period and notice required to prevent renewal, e.g. 'Yes – renews annually unless 30 days written notice given'."
    },
    {
      predefined_key: "termination_for_convenience",
      label: "Termination for Convenience",
      question: "Can either party terminate this contract for convenience without cause? Answer 'Yes' or 'No'. If yes, state any applicable notice period, e.g. 'Yes – 90 days written notice'."
    },
    {
      predefined_key: "liability_cap",
      label: "Liability Cap",
      question: "What is the maximum cap on liability under this contract? Return a short answer, e.g. '£1,000,000' or '12 months of fees paid'. If multiple caps apply, give a brief summary."
    },
    {
      predefined_key: "confidentiality",
      label: "Confidentiality",
      question: "Does this contract include confidentiality or non-disclosure obligations? Answer 'Yes' or 'No'. If yes, note the duration if specified, e.g. 'Yes – 3 years post-termination'."
    },
    {
      predefined_key: "intellectual_property",
      label: "Intellectual Property",
      question: "Who owns intellectual property created or used under this contract? Return a brief summary, e.g. 'Client owns all deliverables; supplier retains background IP'."
    },
    {
      predefined_key: "dispute_resolution",
      label: "Dispute Resolution",
      question: "How are disputes resolved under this contract? Return a short answer, e.g. 'Arbitration under ICC Rules in London' or 'Courts of England and Wales'."
    },
    {
      predefined_key: "indemnification",
      label: "Indemnification",
      question: "What indemnification obligations exist? Return a brief summary, e.g. 'Each party indemnifies the other for IP infringement claims' or 'Supplier indemnifies client against third-party claims'."
    },
    {
      predefined_key: "force_majeure",
      label: "Force Majeure",
      question: "Does this contract include a force majeure clause? Answer 'Yes' or 'No'. If yes, briefly note what events are covered if specified."
    }
  ].freeze

  belongs_to :project
  has_many :extractions, dependent: :destroy

  validates :label, presence: true
  validates :question, presence: true

  scope :predefined, -> { where.not(predefined_key: nil) }
  scope :custom, -> { where(predefined_key: nil) }

  def self.create_predefined_for!(project)
    PREDEFINED_FIELDS.each_with_index do |attrs, i|
      project.fields.create!(attrs.merge(position: i + 1))
    end
  end
end
