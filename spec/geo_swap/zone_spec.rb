require_relative '../../lib/geo_swap/zone'

module GeoSwap
  describe Zone do


    describe 'finding number from lat long' do


      ZONE_DATA = [
        { long: -180.0, zone_number: 1 },
        { long: -147.0, zone_number: 6 },
        { long: -139.0, zone_number: 7 },
        { long: 0.0, zone_number: 31 },
        { long: 62.0, zone_number: 41 },
        { long: 71.0, zone_number: 42 },
        { long: 110.0, zone_number: 49 },
        { long: 141.0, zone_number: 54 },
        { long: 180.0, zone_number: 60 },
      ]

      it 'applys the zone formula correctly' do
        ZONE_DATA.each do |data|
          Zone.new(0, data[:long]).number.should == data[:zone_number]
        end
      end

    end

    describe 'determining the zone origin' do
      it 'can migrate from too far left' do
        Zone.new(0, -180).origin.should == -177
      end

      it 'can migrate from too far right' do
        Zone.new(0, 180).origin.should == 177
      end

      it 'doesnt change the value when the long is already the origin' do
        Zone.new(0, 3).origin.should == 3
      end
    end

  end
end
