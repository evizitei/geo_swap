module GeoSwap
  class Zone
    def initialize(latitude, longitude)
      @latitude = latitude
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

    def letter
      case @latitude
      when 72..84   then 'X'
      when 64...72  then 'W'
      when 56...64  then 'V'
      when 48...56  then 'U'
      when 40...48  then 'T'
      when 32...40  then 'S'
      when 24...32  then 'R'
      when 16...24  then 'Q'
      when 8...16   then 'P'
      when 0...8    then 'N'
      when -8...0   then 'M'
      when -16...-8 then 'L'
      when -24...-16 then 'K'
      when -32...-24 then 'J'
      when -40...-32 then 'H'
      when -48...-40 then 'G'
      when -56...-48 then 'F'
      when -64...-56 then 'E'
      when -72...-64 then 'D'
      when -80...-72 then 'C'
      else
        'Z'
      end
    end
  end
end
