class PlainWorkForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :work
  attr_accessor :name, :description, :model_id, :cover_image, :work_type,
                :featured, :user_id, :crop_x, :crop_y, :crop_w, :crop_h

  validates :name, :product, presence: true

  delegate :persisted?, to: :work, allow_nil: true

  def work=(work)
    @work = work
    @name = work.name
    @description = work.description
    @model_id = work.product.id
    @cover_image = work.cover_image
    @work_type = work.work_type
    @featured = work.featured
    @user_id = work.user.id
  end

  def model_id=(model_id)
    @model_id = model_id
    @product = nil
  end

  def product
    @product ||= ProductModel.find(@model_id)
  end

  def user_id=(user_id)
    @user_id = user_id
    @user = nil
  end

  def user
    @user ||= User.find(user_id)
  end

  def save
    if valid?
      @work ||= Work.new
      @work.update(
        name: name,
        description: description,
        product: product,
        cover_image: cover_image,
        work_type: work_type,
        feature: featured,
        crop_x: crop_x,
        crop_y: crop_y,
        crop_w: crop_w,
        crop_h: crop_h,
        user: user,
        uuid: UUIDTools::UUID.timestamp_create.to_s
      )
    end
  end

  def update_attributes(attributes)
    attributes.each do |key, value|
      send("#{key}=", value)
    end
    save
  end
end
