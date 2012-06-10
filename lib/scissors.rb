require 'nokogiri'
require 'open-uri'
require 'timeout'
require 'netfix'

class Scissors
  def self.cut(url, arg)
    doc = Nokogiri::HTML(open(url))
    p doc.css("body").text
  end

end
