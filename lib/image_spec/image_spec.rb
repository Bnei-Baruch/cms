require 'image_spec/parsers/jpeg'
require 'image_spec/parsers/png'
require 'image_spec/parsers/gif'
require 'image_spec/parsers/bmp'
require 'image_spec/parsers/swf'

module ImageSpec
  
  class Dimensions
    attr_reader :width, :height
    
    def initialize(file)
      # Depending on the type of our file, parse accordingly
      case File.extname(file)
      when '.swf'
        @width, @height = SWF.dimensions(file)
      when '.jpg', '.jpeg', '.pjpeg'
        begin
          @width, @height = JPEG.dimensions(file)
        rescue Exception => ex
          begin
            @width, @height = BMP.dimensions(file)
          rescue Exception => ex1
            raise ex
          end
        end
      when '.gif'
        @width, @height = GIF.dimensions(file)
      when '.bmp'
        @width, @height = BMP.dimensions(file)
      when '.png'
        @width, @height = PNG.dimensions(file)
      when '.eps', '.postscript'
        @width, @height = 0, 0
      else
        raise "Unsupported file type (#{file}). Sorry bub :("
      end
    end
    
  end
  
end
