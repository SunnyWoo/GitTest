class Admin::CountriesController < AdminController
  SUPPORTED_COUNTRIES = [
    'Australia',
    'Canada',
    'China',
    'France',
    'Germany',
    'Hong Kong',
    'Japan',
    'Macao',
    'New Zealand',
    'Korea (South)',
    'Taiwan',
    'Singapore',
    'Malasia',
    'United Kingdom',
    'United States'
  ]

  def index
    render json: supported_countries
  end

  private

  def supported_countries
    SUPPORTED_COUNTRIES.map do |c|
      country = Country.find_country_by_name(c)
      { name: country.name, code: country.alpha2 }
    end
  end
end
