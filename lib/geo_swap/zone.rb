module GeoSwap
  class Zone
    def initialize(longitude)
      @longitude = longitude.to_f
    end

    def number
      @number ||= begin
        number = ((@longitude + 180.0) / 6.0).floor + 1
        #special case for longitude 180.0
        (number > 60) ? 60 : number
      end
    end

    def origin
      @origin ||= ((number - 1) * 6) - 177
    end
  end
end
