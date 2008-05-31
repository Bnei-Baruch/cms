require 'csv'

# {:status => '404'} - removed from the system in perpose                                   
# nil - not found in our table or not active
# {:status => '301', :target => 'http://www.kab.co.il'} - redirected

class UrlMigration < ActiveRecord::Base  
  before_save :trim_strings

  def check_nil(str)
    if (str != nil)
      return str
    else
      return ""
    end

  end

  def self.get_action_and_target(source)
    migration = find :first, :conditions => [ "source = ? AND upper(state) = ?", source, "ACTIVE" ]
    if (migration)
      if (migration.action == $config_manager.appl_settings[:url_migration_action][:action_404])
        return {:status => migration.action}
      else	
        return {:status => migration.action, :target => migration.target}
      end
    else
      return nil
    end
  end

  def self.update_from_file(buf, delete_existing_migrations)
    error_str = ""
    if (delete_existing_migrations)
      url_migrations = find(:all)
      url_migrations.each do |url_migration|
        url_migration.update_attributes(:state => $config_manager.appl_settings[:url_migration_states][:state_delete])
      end
    end      
    
    CSV::Reader.parse(buf).each_with_index do |row, index|
      if (!is_empty(row)) 
        if (index > 0)  
          url_migration = find_by_source(row[0])
          if (url_migration)
            url_migration.update_attributes(:target => row[1], :action => row[2], :state  => row[3])
          else
            url_migration = new(:source => row[0], :target => row[1], :action => row[2],:state  => row[3])		
          end
          if (url_migration.save != true)
            error_str = error_str + "Error in line " + (index + 1).to_s + "<br />"
          end
        else
          if (validate_header(row) != true)
            error_str = error_str + "Header structure is not valid!<br />"
          end
        end
      end
    end

    return error_str
  end

  protected
  def fixed_str(str)
    if (str != nil)
      return str.strip.downcase
    else
      return str
    end
  end

  def self.is_empty(row)
    row.each do |col|
      if (col != nil and col.strip != "") 
        return false
      end
    end
    
    return true
  end
  
  def self.validate_header(row)
    if (row.length != 4)
      return false
    end

    #$config_manager.appl_settings[:url_migration_fields].each_with_index do |state, status,index|
    #  if (col.strip.downcase != $config_manager.appl_settings[:url_migration_fields].to_ary[index].strip.downcase)
    #    return false
    # end

    return true
  end

  def trim_strings
    source = fixed_str(source)
    target = fixed_str(target)
    action = fixed_str(action)
    state = fixed_str(state)
  end

  def valid_arr(field, form_field, arr, error_string)
    found = false
    error_details = ""
    last_one = arr.length - 1
    arr.each_with_index do |action_name, index|
      error_details += action_name[1]
      if index == last_one-1
        error_details += " or "
      else 
        if index >= 0 and index < last_one
          error_details += ", "
        end
      end

      if fixed_str(form_field) == fixed_str(action_name[1])
        found = true
        break
      end
    end

    errors.add(field, error_string + error_details) if found == false
  end

  def validate_url(field, url)
    uri = URI.parse(fixed_str(url))
    if uri.class != URI::HTTP && uri.class != URI::HTTPS && uri.class != URI::FTP
      errors.add(field, 'is not a valid URL addresses')
    end
  rescue URI::InvalidURIError
    errors.add(field, 'is not a valid URL addresses')
  end

  def validate
    valid_arr(:action, action, $config_manager.appl_settings[:url_migration_action], "must be: ")
    valid_arr(:state, state, $config_manager.appl_settings[:url_migration_states], "must be: ")
    validate_url(:source, source)
    validate_url(:target, target) if fixed_str(action) == "301"
  end

end
