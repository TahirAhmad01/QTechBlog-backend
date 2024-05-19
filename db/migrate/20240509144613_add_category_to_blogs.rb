class AddCategoryToBlogs < ActiveRecord::Migration[6.0]
  def change
    add_reference :blogs, :category, foreign_key: true, null: true
  end
end
