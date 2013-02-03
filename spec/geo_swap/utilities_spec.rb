require_relative '../../lib/geo_swap/utilities'

module GeoSwap
  describe Utilities do
    describe 'degrees_to_radians' do
      DEG_RAD_DATA = [[180, Math::PI], [0, 0], [360, (2 * Math::PI)]]

      it 'converts numbers accurately' do
        DEG_RAD_DATA.each do |(deg, rad)|
          Utilities.degrees_to_radians(deg).should == rad
        end
      end
    end
  end
end
