require('yaml')

class ProductIntroPage

  SOURCE = YAML.load(File.read(Rails.root.join('config', 'product_intro_page.yml')))

  class << self

    def find(category_key)
      (SOURCE['categories'][category_key]).deep_symbolize_keys!()
    end

    def find!(category_key)
      product_intro = find(category_key)
      fail RecordNotFoundError if product_intro.blank?
      product_intro
    end

    def find_by(key)
      SOURCE[key]
    end

  end

end

