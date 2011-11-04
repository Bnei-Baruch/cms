# This module was originally written by Dave Troy
# You can find the original post here: http://davetroy.blogspot.com/2007/12/automatic-asset-minimization-and.html

module ActionView
  module Helpers
    module AssetTagHelper
      class AssetTag
        require 'jsminlib'

        def compress_css(source, path)
          # We need to replace relative url(xxx) to be relative regarding a new directory of the cached CSS file
          url_base = File.dirname(path)
          url_base.gsub!(/.+\/public\//, '')
          source.gsub!(/url\((\.\..+)\)/, 'url(' + url_base + '/\1)')
          source.gsub!(/\s+/, ' ')           # collapse space
          source.gsub!(/\/\*(.*?)\*\/ /, '') # remove comments
          source.gsub!(/\} /, "}\n")         # add line breaks
          source.gsub!(/\n$/, '')            # remove last break
          source.gsub!(/ \{ /, ' {')         # trim inside brackets
          source.gsub!(/; \}/, '}')          # trim inside brackets
          source
        end
      
        def contents
          contents = File.read(asset_file_path)
          if asset_file_path =~ /\.min\.js$/
            contents + ";\n\n"
          elsif asset_file_path =~ /\.js$/
            JSMin.minimize(contents) + ";\n\n"
          elsif asset_file_path =~ /\.css$/
            contents = compress_css(contents, asset_file_path) + "\n\n"
          end
        end

      end
    end
  end
end
