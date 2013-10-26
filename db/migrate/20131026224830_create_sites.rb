class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :name

      t.timestamps
    end
    Site.create name: "yr.no"
    Site.create name: "shmu.sk"
    Site.create name: "accuweather.com"
    Site.create name: "weather.com"
  end
end
