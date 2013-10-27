require 'capybara/dsl'
require 'capybara/mechanize'
include Capybara::DSL

class HomeController < ApplicationController


  def index
    if params[:searchbox]
      Capybara.current_driver = :mechanize
      Capybara.javascript_driver = :mechanize
      Capybara.default_driver = :mechanize
      Capybara.app = "something not null"
      @temps = {}
      weather
      yrno
    end
  end

  def weather_site(name, url, searchfield, buttons, container, daywrapper, date_element, temp_element, celsius)
    site = Site.where(name: name).first_or_create
    site_url = site.url_for params[:searchbox]
    if site_url
      page.visit(site_url.url)
      puts page.title
    else
      Capybara.app_host = url
      page.visit('/')
      puts page.title
      page.find(searchfield).set(params[:searchbox])
      buttons.each do |button|
        if page.has_css? button
          elem = page.first(button)
          if elem[:href].nil? or elem[:href] == URI.encode(elem[:href])
            elem.click
          else
            page.visit URI.encode(elem[:href])
          end
          puts page.title
        end
      end
      SiteUrl.create url: current_url, search_string: params[:searchbox], site: site
    end

    if page.has_css?(container)
      if daywrapper.is_a? Array
        datewrapper_selector = "#{container} #{daywrapper[0]}".strip
        tempwrapper_selector = "#{container} #{daywrapper[1]}".strip
      else
        datewrapper_selector = tempwrapper_selector = "#{container} #{daywrapper}".strip
      end
      (1..page.all(datewrapper_selector).size).to_a.each do |i|
        if page.has_css?("#{datewrapper_selector}:nth(#{i}) #{date_element}".strip) and page.has_css?("#{tempwrapper_selector}:nth(#{i}) #{temp_element}".strip)
          date_string = page.find("#{datewrapper_selector}:nth(#{i}) #{date_element}".strip).text
          begin
            date = Date.parse date_string 
          rescue ArgumentError
            date = Date.parse date_string.norway_to_english_month
          end
          temp = page.find("#{tempwrapper_selector}:nth(#{i}) #{temp_element}".strip).text.to_i
          temp = temp.fahrenheit_to_celsius unless celsius
          @temps[date] ||= {}
          @temps[date][name] = temp
        end
      end
    end
  end

  def yrno
    weather_site("yr.no", "http://www.yr.no/", ".yr-search-searchfield", ['.yr-search-searchbutton', '.yr-table-search-results tr td:nth(2) a', '.yr-icon-longterm'], '.yr-table-longterm', ['th', 'tr:nth(2) td'], 'span', '', true)
  end

  def weather
    weather_site("weather.com", "http://www.weather.com/", "#typeaheadBox", ['.wx-searchButton','.searchResultsList a','.wx-vnav:contains("10 Day")'], '#wx-forecast-container', '.wx-daypart', 'h3 .wx-label', '.wx-conditions .wx-temp', false)
  end

  def accuweather
    site = Site.where(name: "accuweather.com").first
    site_url = site.url_for params[:searchbox]
    if site_url
      @accutable = site_url.url
    else
      Capybara.app_host = "http://www.accuweather.com/"
      page.visit('/')
      puts page.title
      page.find('#findcity #s').set(params[:searchbox])
      page.find('#findcity .bt-go').click
      puts page.title
      page.click_link_or_button 'Extended'
      page.evaluate_script("acm_updateUnits('1');")
      @accutable = page.evaluate_script("document.getElementById('feed-tabs').innerHTML")
      SiteUrl.create url: @accutable, search_string: params[:searchbox], site: site
    end
  end
end
