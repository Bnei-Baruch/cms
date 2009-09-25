require 'benchmark'

class RemoveFileFromAttachments < ActiveRecord::Migration
  STEP = 100

  def self.up
    total_attachments = Attachment.count
    offset = 0
    exceptions = 0
    while offset < total_attachments
      puts "Attachments #{offset} - #{offset + STEP - 1} of #{total_attachments}"
      puts Benchmark.measure("TOTAL:") {
        Attachment.find(:all, :offset => offset, :limit => STEP).each { |a|

          fname = a.thumbnail_id ? a.filename : 'original'
          format = a.mime_type.split("/")[1]
          image_name = "#{fname}.#{format}"
#          puts "Image: #{a.id}_#{image_name} (#{a.mime_type})"
          begin
            Attachment.save_as_file(a, a.id, "#{image_name}", false, a.file)
          rescue Exception => ex
            puts "Exception: #{ex}..."
            exceptions += 1
          end
        }
        offset += STEP
      }
    end
    raise "There were #{exceptions} exceptions" if exceptions > 0

    execute 'alter table attachments drop column file;'
  end

  def self.down
    add_column :attachments, :file, :binary
  end
end
