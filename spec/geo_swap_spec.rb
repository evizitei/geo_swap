require_relative '../lib/geo_swap'

module GeoSwap

  describe GeoSwap do
    DATA = [
      {
        lat: 29.979175,
        long: 31.1343583,
        utm: "36R 320010mE 3317942mN",
      },
      {
        lat: 41.8901694,
        long: 12.4922694,
        utm: "33T 291952mE 4640622mN",
      }
    ]

    describe 'lat_long_to_utm' do
      def conversion(lat, long)
        GeoSwap.lat_long_to_utm(lat, long)
      end

      def check_error(lat, long, message)
        expect { conversion(lat, long) }.
          to raise_error(InputError, message)
      end

      it 'rejects data too close to the north pole' do
        check_error(84.1, 0.0, 'Conversions are unreliable close to the polar regions')
      end

      it 'rejects data too close to the south pole' do
        check_error(-80.1, 0.0, 'Conversions are unreliable close to the polar regions')
      end

      it 'rejects data outside the possible lat/long range' do
        check_error(0.0,200.0, 'Input coordinates are invalid')
      end

      it 'correctly converts several reference points' do
        DATA.each do |data|
          GeoSwap.lat_long_to_utm(data[:lat], data[:long]).to_s.
            should == data[:utm]
        end
      end
    end
  end

end
