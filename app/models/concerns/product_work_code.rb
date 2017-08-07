module ProductWorkCode
  extend ActiveSupport::Concern

  included do
    has_one :work_code, as: :work

    after_create :generate_work_code

    delegate :product_code, to: :work_code, allow_nil: true
  end

  # 解决user不存在的问题
  #  当user不存在 就当是客制化好了
  def user_code
    return user.code if user.present?
    '0000'
  end

  private

  def generate_work_code
    WorkCode.create_work_code(self)
  end
end
