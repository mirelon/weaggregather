class Site < ActiveRecord::Base
  has_many :site_urls
  attr_accessible :name

  def url_for(search_string)
    site_urls.where(search_string: search_string).first
  end

end
