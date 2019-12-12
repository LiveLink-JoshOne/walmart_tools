#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'json'
require 'pp'

## Extract product prices from Walmart site using Nokogiri

class Walmart
  attr_accessor :data, :product_urls
  def initialize()
    @data = Hash.new
    @product_urls = {
      :prints => { :url => 'https://photos3.walmart.com/about/prints', :sect_title => nil },
      :calendars => { :url => 'https://photos3.walmart.com/about/calendars', :sect_title => 'Shop by Size' },
      :canvas => { :url => 'https://photos3.walmart.com/about/wall-art', :sect_title => 'Shop Deals on Canvas Prints'},
      :hard_custom_classic => { :url => 'https://photos3.walmart.com/category/385-full-photo--designed-books?cover=hard%20cover&_sort=price-low-to-high&size=', :size => ['8x8', '8x11', '11x14', '12x12'] },
      :premium_layflat => { :url => 'https://photos3.walmart.com/category/385-full-photo--designed-books?cover=premium%20layflat&_sort=price-low-to-high&size=', :size => ['8x8', '8x11', '11x14', '12x12'] },
      :basic_fleece => { :url =>'https://photos3.walmart.com/category/353-full-photo--designed-blankets?_sort=price-low-to-high&size=', :size => ['50x60%20fleece', '60x80%20fleece'] },
      :sherpa => { :url =>'https://photos3.walmart.com/category/353-full-photo--designed-blankets?_sort=price-low-to-high&size=', :size => ['50x60%20sherpa', '60x80%20sherpa'] },
      :mug => { :url => 'https://photos3.walmart.com/category/271-full-photo--designed-ceramic-mugs?_sort=price-low-to-high&size=', :size => ['11oz', '15oz'] },
      :phone_cover => { :url => 'https://photos3.walmart.com/category/52-full-photo--designed-phone-cases?_sort=price-low-to-high&type=', :size => ['iphone%206%2F6s', 'galaxy%20s6'] }
    }
  end

  def self.data
    @data
  end
    
  def prints
    prints = Nokogiri::HTML(open('https://photos3.walmart.com/about/prints')).at('.table-striped-manual')
    size = String.new
    @data[:prints] = Hash.new
    prints.search('tbody').search('tr').each do |tr|
      count = 0
      values = tr.search('td')
      if values.length == 4
        puts('Primary size row')
	size = tr.search('h6').text
	@data[:prints][size] = Array.new
        values = values[1..3]
      else
        puts('Secondary size row')
        count += 1
      end
      @data[:prints][size] << {
        :quantity => values[0].text,
        :price_1hr => values[1].text,
	:price => values[2].text[/^(\$)(\d+)(\.)(\d{2})/]
      }
    end
    pp @data
  end

  def gifts(gifts_name) ## Search title must be the title of the <section> element containing the product data
    gifts_sym = gifts_name.to_s.to_sym
    @data[gifts_sym] = Hash.new
    gifts = nil
    Nokogiri::HTML(open(@product_urls[gifts_sym][:url])).css('section').each do |c|
      if c.attribute('title').text == @product_urls[gifts_sym][:sect_title]
        gifts = c.search('div').select { |d| d.attribute('class').value == 'row' }.first
        break
      end
    end
    gifts.search('div').each do |d|
      size = d.at('p').text.gsub("%20", '_').gsub('%2F', '/')
      price = d.at('p').search('b').text[/^(\$)(\d+)(\.)(\d{2})/]
      @data[gifts_name.to_s.to_sym][size] = { :price => price }
    end
    pp @data
  end

  def prism(gifts_name)
    gifts_sym = gifts_name.to_s.to_sym
    @data[gifts_sym] = Hash.new
    @product_urls[gifts_sym][:size].each do |s|
      url = [@product_urls[gifts_sym][:url], s].join('')
      items = Nokogiri::HTML(open(url)).css('section').select { |s| s.attribute('class').value == 'products' }.first
      begin
        price = items.search('p').select { |p| p.attribute('class').value == 'price' }.first.text
      rescue NoMethodError => e
        price = nil
      end
      @data[gifts_sym][s[/^(\d+)(x)(\d+)/]] = { :price => price }
    end
    pp @data
  end

end

=begin
## Run in irb:
  require '/path/to/walmart.rb'
  x = Walmart.new
  x.prints
  x.gifts('calendars')
  x.gifts('canvas')
  x.prism('hard_custom_classic')
  x.prism('premium_layflat')
  x.prism('basic_fleece')
  x.prism('sherpa')
  x.prism('mug')
  x.prism('phone_cover')
  x.data  ## Show all data
=end
