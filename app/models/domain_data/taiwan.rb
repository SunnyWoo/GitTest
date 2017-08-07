class DomainData::Taiwan
  GEODATA = YAML.load_file(Rails.root.join('config', 'taiwan_city_codes.yml'))

  class << self
    def dists
      Dist
    end

    def cities
      City
    end
  end

  class City
    class << self
      include Enumerable
      delegate :each, :size, to: :all

      def all
        @data ||= load_data
      end

      def load_data
        DomainData::Taiwan::GEODATA.map { |city_data| new(city_data) }
      end
    end

    attr_reader :name, :dists

    def initialize(dat)
      @name = dat['name']
      @dists = dat['dists'].map { |d|
        DomainData::Taiwan::District.new(d.merge('cityname' => @name, 'city' => self))
      }
    end
  end

  class District
    class << self
      include Enumerable
      delegate :each, :size, to: :all

      def [](code)
        dictionary[code.to_s]
      end

      def all
        dictionary.values
      end

      def dictionary
        @dictionary ||= load_dictionary
      end

      def load_dictionary
        DomainData::Taiwan::City.all.each_with_object({}) do |city, dict|
          city.dists.each do |dist|
            dict[dist.code] = dist
          end
        end
      end
    end

    attr_reader :name, :code, :fullname, :cityname, :city

    def initialize(data)
      @name = data['name']
      @fullname = data['fullname']
      @code = data['code']
      @cityname = data['cityname']
      @city = data['city']
    end
  end
end
