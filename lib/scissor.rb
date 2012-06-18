require 'nokogiri'
require 'open-uri'
require 'timeout'
require 'netfix'

class Scissor
  def self.cut(url, arg)
    doc = Nokogiri::HTML(open(url))
    preload_scripts = doc.xpath('//script/@src')
    onpage_scripts = doc.xpath('//script')
    builder = Nokogiri::HTML::Builder.new do |doc|
      doc.html {
        doc.head{
          preload_scripts.each do |s|
            doc.script(:href => s.content)
          end
        }
      }
    end
  end

end
