module ImageSpec

  class BMP
    
    def self.dimensions(file)
      d = IO.read(file, 14, 14)
      d[0] == 40 ? d[4..-1].unpack('LL') : d[4..8].unpack('SS')
    end
  
  end
  
end
