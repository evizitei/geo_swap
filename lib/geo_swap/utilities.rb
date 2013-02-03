
module GeoSwap::Utilities

  def degrees_to_radians(degrees)
    degrees * (Math::PI / 180)
  end

  module_function :degrees_to_radians

end
