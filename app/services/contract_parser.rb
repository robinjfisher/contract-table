class ContractParser
  PDF_TYPE  = "application/pdf"
  DOCX_TYPE = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"

  def initialize(contract)
    @contract = contract
  end

  def pages
    case @contract.file.content_type
    when PDF_TYPE  then PdfExtractor.new(@contract).pages
    when DOCX_TYPE then DocxExtractor.new(@contract).pages
    else raise ArgumentError, "Unsupported content type: #{@contract.file.content_type}"
    end
  end
end
