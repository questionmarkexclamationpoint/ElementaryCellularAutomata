require_relative 'automaton'

require 'optparse'
require 'rmagick'

def write_image(rule, neighbors, width, height, value)
  a = Automaton.new(rule: rule, neighbors: neighbors, size: width, value: value)
  image = Magick::Image.new(a.array.size, height){ |i| i.background_color = 'black' }
  end_hue = rand(360)
  hue = rand(360)
  increment = (end_hue - hue) / height.to_f
  saturation = 255
  lightness = 122
  alpha = 1.0
  on = Magick::Pixel.from_hsla(hue, saturation, lightness, alpha)
  off = Magick::Pixel.from_hsla(0, 0, 0, 0)
  a.step(height).with_index do |arr, i|
    on = Magick::Pixel.from_hsla(hue, saturation, lightness, alpha)
    hue += increment
    arr.each.with_index do |bit, j|
      image.pixel_color(j, i, on) if bit == 1
    end
  end
  image.write("#{ neighbors }.#{ rule }.png")
end

if __FILE__ == $0
  options = {
    neighbors: 3,
    height: 1000,
    width: 500
  }
  OptionParser.new do |opts|

    opts.on('-nNEIGHBORS', '--neighbors=NEIGHBORS') do |n|
      options[:neighbors] = n.to_i
    end

    opts.on('-hHEIGHT', '--height=HEIGHT') do |h|
      options[:height] = h.to_i
    end

    opts.on('-wWIDTH', '--width=WIDTH') do |w|
      options[:width] = w.to_i
    end
    
    opts.on('-vVALUE', '--value=VALUE') do |v|
      options[:value] = v.to_i
    end
  end.parse!
  if options[:value].nil?
    b = BitArray.new(options[:width])
    b[options[:width] / 2] = 1
    options[:value] = b.value
  end
  puts options[:value]
  (1 << (1 << options[:neighbors])).times do |i|
    write_image(i, options[:neighbors], options[:width], options[:height], options[:value])
  end
end