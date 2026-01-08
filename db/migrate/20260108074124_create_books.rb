class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.string :author
      t.text :description
      t.string :publisher
      t.string :isbn
      t.date :published_on
      t.string :language, default: "en"
      t.string :file_type
      t.integer :file_size

      t.timestamps
    end

    add_index :books, :title
    add_index :books, :author
    add_index :books, :file_type
  end
end
