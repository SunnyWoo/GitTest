class Admin::ProductCodeForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :record, :code_type, :code, :description, :id

  VALID_CODE_TYPES = %w(category_code material craft spec)
  validates :code_type, inclusion: { in: VALID_CODE_TYPES, message: '%{value} is not a valid size' }
  validates :code_type, presence: true
  validates :code, presence: true

  def self.code_types_collection
    VALID_CODE_TYPES.map do |code_type|
      [I18n.t("product_codes.#{code_type}"), code_type]
    end
  end

  def save!
    if valid?
      @record = model_class.create(description: description, code: code)
    else
      fail ActiveRecord::RecordInvalid, self
    end
  end

  def update!
    member.update!(description: description)
  end

  def member
    model_class.find(id)
  end

  private

  def model_class
    "product_#{code_type}".classify.constantize
  end
end
