module GeoSwap
  class UtmPoint

    attr_reader :zone, :easting, :northing, :hemisphere

    def initialize(attrs)
      @easting = attrs.fetch(:easting)
      @northing = attrs.fetch(:northing)
      @zone = attrs.fetch(:zone)
      @hemisphere = attrs.fetch(:hemisphere)
    end

    def to_s
      "#{zone.number}#{zone.letter} #{easting}mE #{northing}mN"
    end

  end
end
