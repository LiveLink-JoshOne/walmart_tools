#!/usr/bin/env ruby
## Use in conjunction with bin/missing_images

def check_img(url)
  puts "Checking #{url}"
  return false if `curl -I "#{url}"` =~ /404 [Nn]ot [Ff]ound/
  true
end

def check_img_urls(url_arr)
  missing_count = 0
  missing_images = []

  url_arr.each do |url|
    if check_img(url) == false
      missing_count += 1
      missing_images.push(url)
    end
    puts "Missing #{missing_count} images so far"
  end
  puts '-------------------------------------------------'
  puts "Missing images: #{missing_images.to_s}"
  puts "Missing images count: #{missing_count}"
  if missing_count != 0
    puts ''
    puts 'Would you like to retry the missing images? [y/n]'
    retry_ans = STDIN.gets.strip
    if retry_ans == 'y'
      check_img_urls(missing_images)
    end
  end
end
