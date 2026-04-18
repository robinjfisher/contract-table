class AddAnnotationToExtractions < ActiveRecord::Migration[8.1]
  def change
    add_column :extractions, :annotation, :text
  end
end
