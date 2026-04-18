class AnthropicClient
  MODEL = "claude-haiku-4-5-20251001"
  PDF_TYPE = "application/pdf"

  def initialize
    api_key = ENV["ANTHROPIC_API_KEY"] || Rails.application.credentials.anthropic_api_key!
    @client = Anthropic::Client.new(api_key: api_key)
  end

  # Extracts all fields from a contract in a single API call.
  #
  # contract - Contract record with an Active Storage file attachment
  # fields   - Array of Field records to extract
  #
  # Returns Hash of { field_id => { value:, source_text:, source_page: } }
  def extract_all(contract:, fields:)
    return {} if fields.empty?

    questions = fields.map { |f| "- Field ID #{f.id} (#{f.label}): #{question_with_hint(f)}" }.join("\n")
    prompt = <<~TEXT
      You are a contract analysis assistant. Extract the following fields from the contract.
      For each field, use the field ID exactly as given. If a value is not present, set it to null.

      Fields to extract:
      #{questions}
    TEXT

    response = @client.messages.create(
      model: MODEL,
      max_tokens: 4096,
      tools: [ batch_extraction_tool(fields) ],
      tool_choice: { type: "any" },
      messages: [ { role: "user", content: document_content(contract, prompt) } ]
    )

    Rails.logger.info "AnthropicClient#extract_all: stop_reason=#{response.stop_reason} content=#{response.content.map { |b| "#{b.class}(type=#{b.type.inspect})" }.inspect}"

    tool_use = response.content.find { |b| b.type.to_s == "tool_use" }
    unless tool_use
      Rails.logger.warn "AnthropicClient#extract_all: no tool_use block in response"
      return {}
    end

    Rails.logger.info "AnthropicClient#extract_all: raw input=#{tool_use.input.inspect}"

    input = tool_use.input
    extractions = input[:extractions] || input["extractions"] || []
    extractions.each_with_object({}) do |e, h|
      field_id = e[:field_id] || e["field_id"]
      h[field_id] = {
        value:       e[:value]       || e["value"],
        source_text: e[:source_text] || e["source_text"],
        source_page: e[:source_page] || e["source_page"]
      }
    end
  end

  # Extracts a single field from a contract.
  # Used when a new field is added to a project with existing contracts.
  #
  # contract - Contract record with an Active Storage file attachment
  # field    - Field record to extract
  #
  # Returns { value: String, source_text: String, source_page: Integer }
  def extract(contract:, field:)
    prompt = <<~TEXT
      You are a contract analysis assistant. Extract the requested information from the contract.
      If the information is not present, set value to null and leave source fields empty.

      Question: #{question_with_hint(field)}
    TEXT

    response = @client.messages.create(
      model: MODEL,
      max_tokens: 1024,
      tools: [ extraction_tool ],
      tool_choice: { type: "any" },
      messages: [ { role: "user", content: document_content(contract, prompt) } ]
    )

    Rails.logger.info "AnthropicClient#extract: stop_reason=#{response.stop_reason} content=#{response.content.map { |b| "#{b.class}(type=#{b.type.inspect})" }.inspect}"

    tool_use = response.content.find { |b| b.type.to_s == "tool_use" }
    unless tool_use
      Rails.logger.warn "AnthropicClient#extract: no tool_use block in response"
      return { value: nil, source_text: nil, source_page: nil }
    end

    Rails.logger.info "AnthropicClient#extract: raw input=#{tool_use.input.inspect}"

    input = tool_use.input
    {
      value:       input[:value]       || input["value"],
      source_text: input[:source_text] || input["source_text"],
      source_page: input[:source_page] || input["source_page"]
    }
  end

  private

  def document_content(contract, prompt)
    if contract.file.content_type == PDF_TYPE
      [
        {
          type: "document",
          source: {
            type: "base64",
            media_type: PDF_TYPE,
            data: Base64.strict_encode64(contract.file.download)
          }
        },
        { type: "text", text: prompt }
      ]
    else
      pages = ContractParser.new(contract).pages
      full_text = pages.map { |p| "--- Page #{p[:page]} ---\n#{p[:text]}" }.join("\n\n")
      [ { type: "text", text: "#{prompt}\nContract:\n#{full_text}" } ]
    end
  end

  def batch_extraction_tool(fields)
    field_descriptions = fields.map { |f| "#{f.id}: #{f.label}" }.join(", ")
    {
      name: "extract_fields",
      description: "Extract multiple contract field values and their source clauses.",
      input_schema: {
        type: "object",
        properties: {
          extractions: {
            type: "array",
            description: "One entry per field: #{field_descriptions}",
            items: {
              type: "object",
              properties: {
                field_id:    { type: "integer", description: "The field ID as given in the prompt." },
                value:       { type: [ "string", "null" ], description: "Extracted value, or null if not found." },
                source_text: { type: [ "string", "null" ], description: "Verbatim clause the value was drawn from." },
                source_page: { type: [ "integer", "null" ], description: "1-based page number of the source clause." }
              },
              required: [ "field_id", "value", "source_text", "source_page" ]
            }
          }
        },
        required: [ "extractions" ]
      }
    }
  end

  def question_with_hint(field)
    case field.field_type
    when "yes_no"
      "#{field.question} Respond with 'Yes' or 'No' followed by a brief qualification if relevant (max 10 words)."
    when "date"
      "#{field.question} Return the date in ISO 8601 format (YYYY-MM-DD), e.g. '2026-12-31'. Use 'Ongoing' if there is no fixed end date."
    else
      field.question
    end
  end

  def extraction_tool
    {
      name: "extract_field",
      description: "Extract a contract field value and its source clause.",
      input_schema: {
        type: "object",
        properties: {
          value:       { type: [ "string", "null" ], description: "The extracted value, or null if not found." },
          source_text: { type: [ "string", "null" ], description: "The verbatim clause or sentence the value was drawn from." },
          source_page: { type: [ "integer", "null" ], description: "The 1-based page number where the source clause appears." }
        },
        required: [ "value", "source_text", "source_page" ]
      }
    }
  end
end
