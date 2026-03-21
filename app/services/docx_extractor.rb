class DocxExtractor
  def initialize(contract)
    @contract = contract
  end

  def pages
    Tempfile.open([ "contract", ".docx" ], encoding: "ascii-8bit") do |f|
      f.write(@contract.file.download)
      f.flush
      doc = Docx::Document.open(f.path)
      text = doc.paragraphs.map(&:to_s).join("\n")
      [ { page: 1, text: text } ]
    end
  end
end
