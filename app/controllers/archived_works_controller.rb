class ArchivedWorksController < ApplicationController
  before_action :find_work_show, only: 'show'

  def show
    title = "#{@work.name} #{@work.product_name}"
    set_meta_tags title: title,
                  description: @work.description,
                  canonical: shop_work_url(@work.product, @work, locale: I18n.locale),
                  reverse: true,
                  og: {
                    title: "#{title} | #{t('site.name')}",
                    description: @work.description,
                    image: @work.order_image.share.url
                  }

    render 'works/show'
  end

  private

  def find_work_show
    @work = ArchivedWork.find(params[:id])
    @recommend_works = @work.original_work.try(:recommend_works)
  end
end
