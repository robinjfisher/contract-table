class PdfExtractor
  def initialize(contract)
    @contract = contract
  end

  def pages
    bytes = @contract.file.download
    reader = PDF::Reader.new(StringIO.new(bytes))
    reader.pages.each_with_index.map do |page, i|
      { page: i + 1, text: page.text }
    end
  end
end
