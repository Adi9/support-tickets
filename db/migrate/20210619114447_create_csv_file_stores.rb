class CreateCsvFileStores < ActiveRecord::Migration[5.2]
  def change
    create_table :csv_file_stores do |t|
      t.string :url

      t.timestamps
    end
  end
end
