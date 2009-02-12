# This module was originally written by Dave Troy
# You can find the original post here: http://davetroy.blogspot.com/2007/12/automatic-asset-minimization-and.html
# It is being reproduced here because I wanted an easy way to reference it
# config/initializers/javascript_minimization.rb:

module ActionView
  module Helpers
    module AssetTagHelper
      class AssetTag
        require 'jsminlib'

        def compress_css(source)
          source.gsub!(/\s+/, " ")           # collapse space
          source.gsub!(/\/\*(.*?)\*\/ /, "") # remove comments
          source.gsub!(/\} /, "}\n")         # add line breaks
          source.gsub!(/\n$/, "")            # remove last break
          source.gsub!(/ \{ /, " {")         # trim inside brackets
          source.gsub!(/; \}/, "}")          # trim inside brackets
          source
        end
      
        def contents
          contents = File.read(asset_file_path)
          if asset_file_path =~ /\.min\.js$/
            contents + ";\n\n"
          elsif asset_file_path =~ /\.js$/
            JSMin.minimize(contents) + ";\n\n"
            contents + ";\n\n"
          elsif asset_file_path =~ /\.css$/
            contents = compress_css(contents) + "\n\n"
          end
        end

      end
    end
  end
end