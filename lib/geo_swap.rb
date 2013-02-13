require 'pry'
require "geo_swap/version"
require 'geo_swap/zone'
require 'geo_swap/utilities'
require 'geo_swap/utm_point'

module GeoSwap
  extend Utilities

  def lat_long_to_utm(lat, long)
    validate_range(lat, long)
    lat_radians = degrees_to_radians(lat)
    long_radians = degrees_to_radians(long)

    zone = Zone.new(lat, long)
    origin_radians = degrees_to_radians(zone.origin)

    equator_factor = (EQUATORIAL_RADIUS / Math.sqrt(1 - (ECC_SQUARED * (Math.sin(lat_radians) ** 2))))
    squared_lat_tangent = Math.tan(lat_radians) ** 2
    ecc_prime_factor = ECC_PRIME_SQUARED * (Math.cos(lat_radians) ** 2)
    origin_factor = Math.cos(lat_radians) * (long_radians - origin_radians)


    ecc_1 = (1 - ecc(1, 1, 4) - ecc(2, 3, 64) - ecc(3, 5, 256))
    ecc_2 = ecc(1, 3, 8) + ecc(2, 3, 32) + ecc(3, 45, 1024)
    ecc_3 = ecc(2, 15, 256) + ecc(3, 45, 1024)
    ecc_4 = ecc(3, 35, 3072)

    latRad_1 = lat_radians
    latRad_2 = Math.sin(2 * lat_radians)
    latRad_3 = Math.sin(4 * lat_radians)
    latRad_4 = Math.sin(6 * lat_radians)

    northing_factor = EQUATORIAL_RADIUS * (
      ecc_1 * latRad_1 -
      ecc_2 * latRad_2 +
      ecc_3 * latRad_3 -
      ecc_4 * latRad_4
    )

    utm_easting = (MERIDIAN_SCALE * equator_factor * 
      (origin_factor + (1 - squared_lat_tangent + ecc_prime_factor) *
      (origin_factor ** 3) / 6 +
      (5 - 18 * squared_lat_tangent + (squared_lat_tangent ** 2) + 72 * ecc_prime_factor - 58 * ECC_PRIME_SQUARED) *
      (origin_factor ** 5) / 120) + EASTING_OFFSET)

    utm_northing = (
      MERIDIAN_SCALE * ( northing_factor + equator_factor * Math.tan(lat_radians) * (origin_factor ** 2) / 2 + (5 - squared_lat_tangent + 9 * ecc_prime_factor + 4 * (ecc_prime_factor ** 2)) * (origin_factor ** 4) / 2 +
     (61 - 58 * squared_lat_tangent + (squared_lat_tangent ** 2) + 600 * ecc_prime_factor - 330 * ECC_PRIME_SQUARED) *
     (origin_factor ** 6) / 720))

    utm_northing += 10000000 if utm_northing < 0

    UtmPoint.new(
      easting: utm_easting.round,
      northing: utm_northing.round,
      zone: zone,
      hemisphere: (lat < 0 ? 'S' : 'N')
    )
  end

  module_function :lat_long_to_utm

  def utm_to_usng(easting, northing, zone_number, zone_letter, hemisphere = 'N')
    precision = 10
    if hemisphere == 'S'
      northing += NORTHING_OFFSET
    end

    letters = find_grid_letters(zone_number, northing, easting)
    usngNorthing = (northing % BLOCK_SIZE).round
    usngEasting = (easting % BLOCK_SIZE).round

    "#{zone_number}#{zone_letter} #{letters} #{usngEasting} #{usngNorthing}"
  end

  module_function :utm_to_usng

  private

  MAX_LATITUDE = 90.0
  MIN_LATITUDE = -90.0
  MAX_LONGITUDE = 180
  MIN_LONGITUDE = -180
  MAX_CONVERSION_LATITUDE = 84.0
  MIN_CONVERSION_LATITUDE = -80.0

  EQUATORIAL_RADIUS = 6378137.0
  ECC_SQUARED = 0.006694380023
  ECC_PRIME_SQUARED = ECC_SQUARED / (1 - ECC_SQUARED)
  MERIDIAN_SCALE = 0.9996

  EASTING_OFFSET = 500000.0
  NORTHING_OFFSET = 10000000.0

  BLOCK_SIZE  = 100000
  GRIDSQUARE_SET_COL_SIZE = 8
  GRIDSQUARE_SET_ROW_SIZE = 20

  def self.validate_range(lat, long)
    unless lat.between?(MIN_LATITUDE, MAX_LATITUDE) && long.between?(MIN_LONGITUDE, MAX_LONGITUDE)
      raise InputError, 'Input coordinates are invalid'
    end

    unless lat.between?(MIN_CONVERSION_LATITUDE, MAX_CONVERSION_LATITUDE)
      raise InputError, 'Conversions are unreliable close to the polar regions'
    end
  end

  def self.ecc(power, numerator, denominator)
    ecc = ECC_SQUARED ** power
    (numerator * ecc) / denominator
  end

  def self.find_grid_letters(zone_number, northing, easting)
    row = 1
    north_1m = northing.round
    while north_1m >= BLOCK_SIZE do
      north_1m = north_1m - BLOCK_SIZE
      row += 1;
    end
    row = row % GRIDSQUARE_SET_ROW_SIZE

    col = 0
    east_1m = easting.round
    while east_1m >= BLOCK_SIZE
      east_1m = east_1m - BLOCK_SIZE
      col += 1
    end
    col = col % GRIDSQUARE_SET_COL_SIZE

    letters_helper(find_set(zone_number), row, col)
  end

  LETTERS_MAP = [
    { cols: "ABCDEFGH", rows: "ABCDEFGHJKLMNPQRSTUV" },
    { cols: "JKLMNPQR", rows: "FGHJKLMNPQRSTUVABCDE" },
    { cols: "STUVWXYZ", rows: "ABCDEFGHJKLMNPQRSTUV" },
    { cols: "ABCDEFGH", rows: "FGHJKLMNPQRSTUVABCDE" },
    { cols: "JKLMNPQR", rows: "ABCDEFGHJKLMNPQRSTUV" },
    { cols: "STUVWXYZ", rows: "FGHJKLMNPQRSTUVABCDE" }
  ]

  ZONE_TO_SET = [6, 1, 2, 3, 4, 5]

  def self.find_set(zone_number)
    zoneNum = zone_number % 6
    ZONE_TO_SET[zoneNum.to_i] || -1
  end

  def self.letters_helper(set, row, col)
    if row == 0
      row = GRIDSQUARE_SET_ROW_SIZE - 1
    else
      row -= 1
    end

    if col == 0
      col = GRIDSQUARE_SET_COL_SIZE - 1
    else
      col -= 1
    end

    l1 = l2 = nil

    hash = LETTERS_MAP[set - 1]
    hash[:cols][col] + hash[:rows][row]
  end

end

class GeoSwap::InputError < StandardError; end
