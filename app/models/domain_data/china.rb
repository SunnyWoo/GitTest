class DomainData::China
  GEODATA = YAML.load_file(Rails.root.join('config', 'china_city_codes.yml'))

  class << self
    def dists
      Dist
    end

    def cities
      City
    end
  end

  class Province
    class << self
      include Enumerable
      delegate :each, :size, to: :all

      def all
        @data ||= load_data
      end

      def load_data
        DomainData::China::GEODATA.map { |province_data| new(province_data) }
      end
    end

    attr_reader :name, :code, :cities

    def initialize(dat)
      @name = dat['name']
      @code = dat['code']
      @cities = dat['cities'].map { |d|
        DomainData::China::City.new(d.merge('province' => self))
      }
    end

    def id
      ::Province.find_by_code(code).try(:id)
    end
  end

  class City
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
        DomainData::China::Province.all.each_with_object({}) do |province, dict|
          province.cities.each do |city|
            dict[city.code] = city
          end
        end
      end
    end

    attr_reader :name, :code, :province, :dists

    def initialize(dat)
      @name = dat['name']
      @code = dat['code']
      @province = dat['province']
      @dists = dat['dists'].map { |d|
        DomainData::China::District.new(d.merge('cityname' => @name, 'fullname' => "#{@name}#{d['name']}", 'city' => self))
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
        DomainData::China::City.all.each_with_object({}) do |city, dict|
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
