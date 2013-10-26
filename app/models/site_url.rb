class SiteUrl < ActiveRecord::Base
  belongs_to :site
  attr_accessible :url, :search_string, :site
end
