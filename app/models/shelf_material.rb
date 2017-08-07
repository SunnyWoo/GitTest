# == Schema Information
#
# Table name: shelf_materials
#
#  id                    :integer          not null, primary key
#  factory_id            :integer
#  name                  :string(255)
#  serial                :string(255)      not null
#  image                 :string(255)
#  quantity              :integer          default(0), not null
#  safe_minimum_quantity :integer          default(0)
#  scrapped_quantity     :integer          default(0)
#  aasm_state            :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  deleted_at            :datetime
#

class ShelfMaterial < ActiveRecord::Base
  acts_as_paranoid
  include AASM
  include Logcraft::Trackable
  ACTIONS = %i(stock adjust)

  belongs_to :factory
  has_many :shelves, foreign_key: :material_id
  validates :serial, presence: true, uniqueness: { scope: :factory_id }
  validates :quantity, presence: true

  mount_uploader :image, DefaultUploader

  aasm do
    state :single, initial: true
    state :combination
  end

  def stock!(quantity)
    fail ArgumentError, 'quantity should be an integer' unless quantity.is_a? Integer
    with_lock do
      self.quantity += quantity
      save
    end
  end

  def ship!(quantity)
    fail ArgumentError, 'quantity should be an integer' unless quantity.is_a? Integer
    with_lock do
      fail StoreLackingError if quantity > self.quantity
      decrement!(:quantity, quantity)
    end
  end

  def restore!(quantity)
    fail ArgumentError, 'quantity should be an integer' unless quantity.is_a? Integer
    with_lock do
      increment!(:quantity, quantity)
    end
  end

  def available_quantity
    quantity - shelves.reject(&:scrapped_shelf?)
      .inject(0) { |sum, shelf| sum + shelf.quantity }
  end

  def as_json(*)
    super.merge(available_quantity: available_quantity)
  end

  def scrap!(quantity)
    fail ArgumentError, 'quantity should be an integer' unless quantity.is_a? Integer
    with_lock do
      fail StoreLackingError if reload.quantity < quantity
      increment!(:scrapped_quantity, quantity)
      decrement!(:quantity, quantity)
    end
  end
end
