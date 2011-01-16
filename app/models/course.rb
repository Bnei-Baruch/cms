class Course < ActiveRecord::Base
  #  validate_presence :location
  #  validate_presence :name
  #  validate_presence :start_date
  #  validate_presence :end_date
  
  def self.prepare_locations
    all_courses = Course.all
    courses = {}
    locations = all_courses.map{ |c|
      c.location
    }.uniq.sort

    locations.each {|loc|
      courses[loc] = all_courses.select{|ac| ac.location == loc}.sort{|c1, c2|
        c1.name == c2.name ? c1.start_date <=> c1.start_date : c1.name <=> c2.name
      }
    }
    
    [locations, courses]
  end
  
end
