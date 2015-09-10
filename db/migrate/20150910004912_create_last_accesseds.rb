class CreateLastAccesseds < ActiveRecord::Migration
  def change
    add_column :shortened_urls, :last_accessed_at, :datetime
  end
end
