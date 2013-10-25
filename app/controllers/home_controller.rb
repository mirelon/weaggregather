require 'capybara/dsl'
require 'capybara-webkit'
include Capybara::DSL

class HomeController < ApplicationController


  def index
    if params[:searchbox]
      Capybara.current_driver = :webkit
      Capybara.javascript_driver = :webkit
      yrno
      shmu
      accuweather
      weather
    end
  end

  def shmu
    Capybara.app_host = "http://www.shmu.sk/"
    page.visit '/'
    puts page.title
    page.click_link_or_button 'Model ALADIN'
    page.all('#nwp_mesto option').each do |e|
      if e.text.downcase.include? params[:searchbox].downcase
        page.find('#nwp_mesto').select e.text
        @shmusrc = "http://www.shmu.sk/" + page.find('#maincontent .tcenter img')[:src]
        break
      end
    end
  end

  def yrno
    Capybara.app_host = "http://www.yr.no/"
    page.visit('/')
    puts page.title
    unless page.has_css?('.yr-language-switcher span.yr-icon-flag-eng')
      page.find('.yr-language-switcher').click
      if page.has_css?('[title=English]')
        page.first('[title=English]').click
        puts page.title
      end
    end
    page.find('.yr-search-searchfield').set(params[:searchbox])
    page.find('.yr-search-searchbutton').click
    puts page.title
    if page.has_css?('.yr-table-search-results tr a')
      page.first('.yr-table-search-results tr a').click
      puts page.title
      @yrnosrc = current_url + "meteogram.png"
    else
      @yrnosrc = "http://cdn.techi.com/wp-content/themes/techi/images/failed_search2.jpg"
    end
  end

  def accuweather
    Capybara.app_host = "http://www.accuweather.com/"
    page.visit('/')
    puts page.title
    page.find('.loc_search_box').set(params[:searchbox])
    page.find('.bt-go').click
    page.click_link_or_button 'Extended'
    page.evaluate_script("acm_updateUnits('1');")
    @accutable = page.evaluate_script("document.getElementById('feed-tabs').innerHTML")
  end

  def weather
    Capybara.app_host = "http://www.weather.com/"
    page.visit('/')
    puts page.title
    page.find('#wx-temperature-celcius-button').click
    page.find('#typeaheadBox').set(params[:searchbox])
    page.first('.wx-searchButton').click
    page.click_link_or_button '10 Day'    
    @weathertable = page.evaluate_script("document.getElementById('wx-forecast-container').innerHTML")
  end
end
