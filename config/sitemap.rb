return unless Rails.env.production?

SitemapGenerator::Sitemap.default_host = 'https://commandp.com'

SitemapGenerator::Sitemap.create do
  %w(en zh-TW).each do |locale|
    add locale, priority: 1
    add about_path(locale: locale)
    add careers_path(locale: locale)
    add questions_path(locale: locale)
    add search_path(locale: locale)

    # shop list with model
    ProductModel.model_list.each do |model|
      add shop_path(model, locale: locale)
    end

    # product list
    Work.is_public.find_each do |work|
      add shop_work_path(work.product, work, locale: locale)
    end
  end
end

SitemapGenerator::Sitemap.ping_search_engines
