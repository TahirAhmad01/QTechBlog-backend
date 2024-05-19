class AddViewCountToBlogs < ActiveRecord::Migration[7.1]
  def change
    add_column :blogs, :views_count, :integer, default: 0
  end
end
