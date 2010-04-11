require 'image_spec/image_spec'

class Attachment < ActiveRecord::Base
  def Attachment.save_as_file(attachment, name)
    original_image_id = attachment.thumbnail_id ? attachment.thumbnail_id : attachment.id
    path = File.join(File.dirname(__FILE__), '/../../public/images/attachments/', (original_image_id.to_i % 100).to_s)
    file_path = "#{path}/#{original_image_id}_#{name}"
    return file_path if File.exist?(file_path)
    FileUtils.mkdir_p path
    File.open(file_path, "w") {|file|
      file.binmode
      file.write attachment.file
    }
    file_path
  end
end

class RetrieveImagesFromDb < ActiveRecord::Migration
  def self.up
    exceptions_str = []
    total_attachments = Attachment.count
    sum = 0
    exceptions = 0
    Attachment.find_each(:batch_size => 10) { |a|
      sum += 1
      puts "#{sum} of #{total_attachments}" if sum % 100 == 0
      fname = a.thumbnail_id ? a.filename : 'original'
      format = a.mime_type.split("/")[1]
      image_name = "#{fname}.#{format}"
      begin
        is = ImageSpec::Dimensions.new Attachment.save_as_file(a, image_name)
        a.width = is.width
        a.height = is.height
        a.save!
        Attachment.find_by_sql('COMMIT')
        #          puts "Image: #{a.id} #{image_name} #{a.filename} (#{is.width}x#{is.height})"
      rescue Exception => ex
        puts "Image: #{a.id} #{image_name} #{a.filename}"
        exceptions_str << "Image: #{a.id} #{image_name} #{a.filename}"
        puts "Exception: #{ex}..."
        exceptions += 1
      end
    }
    puts exceptions_str if exceptions > 0
    raise "There were #{exceptions} exceptions" if exceptions > 0

  end

  def self.down
  end
end
