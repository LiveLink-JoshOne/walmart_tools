#!/usr/bin/env ruby

## Largely based on Wiki doc:
## https://sites.google.com/a/livelinktechnology.net/intranet/wiki/shared-documentation/knowledge-base/baggage/baggage-troubleshooting/missing-images-in-photo-albums

require 'date'
require 'fileutils'
require 'json'

class WMAlbum

  attr_accessor :options, :zipfile

  def initialize(options = Hash.new)
    app_root = File.expand_path(File.dirname(File.dirname(__FILE__)))
    @options = options
    @options.each { |k,v| FileUtils.mkdir_p(dir) if k.to_s.include?('dir') }
    @zipfile = File.join(@options[:output_dir], @options[:output_file])
    abort('[WMTOOLS][IMAGEALBUM][ERR] Specify a filepath to JSON array of URLS with -f') unless @options[:urls]
  end

  def check_img(url)
    puts("[WMTOOLS][IMAGEALBUM][LOG] Checking #{url}")
    `curl -I "#{url}"` =~ /404 [Nn]ot [Ff]ound/ ? return false : return true
  end

  def download_img(url)
    puts("[WMTOOLS][IMGALBUM][LOG] Downloading image @ #{url}")
    `wget -P #{@options[:temp_dir]} '#{url}'`
  end

  def download_img_urls(check = false)
    failed_count, failed_images = [0, Array.new]
    @options[:urls].each do |url|
      if check
        if check_img(url) == false
          failed_count += 1
	  failed_images.push(url)
	  next
	end
      end
      download_img(url)
    end
    File.rm(@zipfile) if File.exist?(@zipfile)
    `zip -r #{@zipfile} #{File.join(@options[:temp_dir], '')}`
    puts("[WMTOOLS][IMAGEALBUM][LOG] Album downloaded to: #{@zipfile} \n")
    if failed_count != 0
      puts("[WMTOOLS][IMAGEALBUM][LOG] Total missing images: #{failed_count.to_s} \n #{failed_images.to_s}")
      puts('[WMTOOLS][IMAGEALBUM][INPUT] Would you like to retry downloading the missing images? [y/n]')
      retry_ans = STDIN.gets.strip
      download_img_urls(missing_images) if retry_ans == 'y'
    end
    Dir.rmdir(@options[:temp_dir])
  end

  def check_img_urls
    missing_count, missing_images = [0, Array.new]
    @options[:urls].each do |url|
      if check_img(url) == false
        missing_count += 1
        missing_images.push(url)
      end
      puts("[WMTOOLS][IMAGEALBUM][LOG] Missing #{missing_count.to_s} images so far")
    end
    puts('-------------------------------------------------')
    puts("[WMTOOLS][IMAGEALBUM][LOG] Total missing images: #{missing_count.to_s}")
    puts missing_images.to_s
    if missing_count != 0
      puts('')
      puts('[WMTOOLS][IMAGEALBUM][INPUT] Would you like to retry the missing images? [y/n]')
      retry_ans = STDIN.gets.strip
      check_img_urls(missing_images) if retry_ans == 'y'
    end
  end

end
