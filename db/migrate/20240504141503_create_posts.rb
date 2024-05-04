class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.string :description
      t.string :short_description
      t.string :body
      t.json :tags
      t.string :slug
      t.string :blog_status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
