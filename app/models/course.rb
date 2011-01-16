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
      courses[loc] = all_courses.select{|ac| ac.location == loc}.sort_by{|course| course.name}.sort_by{|course| course.start_date}
    }
    
    [locations, courses]
  end
end
