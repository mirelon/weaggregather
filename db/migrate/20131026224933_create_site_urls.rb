class CreateSiteUrls < ActiveRecord::Migration
  def change
    create_table :site_urls do |t|
      t.string :url
      t.string :search_string
      t.integer :site_id
      t.timestamps
    end
  end
end
