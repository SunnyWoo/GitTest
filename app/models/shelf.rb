# == Schema Information
#
# Table name: shelves
#
#  id                    :integer          not null, primary key
#  serial                :string(255)
#  section               :string(255)
#  name                  :string(255)
#  quantity              :integer          default(0)
#  factory_id            :integer
#  created_at            :datetime
#  updated_at            :datetime
#  serial_name           :string(255)
#  safe_minimum_quantity :integer          default(0)
#  material_id           :integer
#  category_id           :integer
#  deleted_at            :datetime
#

class Shelf < ActiveRecord::Base
  acts_as_paranoid
  strip_attributes only: %i(serial section name)
  include Logcraft::Trackable
  ACTIONS = %i(move_in move_out adjust ship stock allocate restore)

  attr_accessor :original_quantity

  belongs_to :factory
  belongs_to :material, class_name: 'ShelfMaterial'
  belongs_to :category, class_name: 'ShelfCategory'

  delegate :name, :description, to: :category, prefix: true, allow_nil: true
  delegate :id, :name, :serial, :image, :quantity, :scrapped_quantity, :safe_minimum_quantity,
           :available_quantity, to: :material, prefix: true, allow_nil: true

  validates :serial, presence: true
  validates :serial, uniqueness: { scope: [:factory_id, :material_id] }
  validate :can_not_change_to_scrapped_shelf

  def stock!(quantity)
    fail ArgumentError, 'quantity should be an integer' unless quantity.is_a? Integer
    if scrapped_shelf?
      fail StoreLackingError if material.reload.quantity < quantity
      scrap_material(quantity)
    else
      fail StoreLackingError if material.reload.available_quantity < quantity
    end
    with_lock do
      self.quantity += quantity
      save
    end
  end

  def ship!(quantity)
    fail ArgumentError, 'quantity should be an integer' unless quantity.is_a? Integer
    with_lock do
      fail ArgumentError, 'not enough quantity' if quantity > self.quantity
      self.quantity -= quantity
      save
    end
    ship_material(quantity) unless scrapped_shelf?
  end

  def move_out!(quantity)
    fail ArgumentError, 'quantity should be an integer' unless quantity.is_a? Integer
    with_lock do
      fail ArgumentError, 'not enough quantity' if quantity > self.quantity
      self.quantity -= quantity
      save
    end
  end

  def move_in!(quantity)
    fail ArgumentError, 'quantity should be an integer' unless quantity.is_a? Integer
    with_lock do
      self.quantity += quantity
      save
    end
  end

  def restore!(quantity)
    fail ArgumentError, 'quantity should be an integer' unless quantity.is_a? Integer
    with_lock do
      increment!(:quantity, quantity)
    end
    restore_material(quantity)
  end

  def scrapped_shelf?
    category_name == '报废'
  end

  def as_json(*)
    super.merge(material: material, category_name: category_name)
  end

  def original_quantity
    quantity
  end

  private

  def can_not_change_to_scrapped_shelf
    errors.add(:base, 'can not change to scrapped shelf') if persisted? && category_id_changed? && scrapped_shelf?
  end

  def scrap_material(quantity)
    material.scrap!(quantity)
  end

  def ship_material(quantity)
    material.ship!(quantity)
  end

  def restore_material(quantity)
    material.restore!(quantity)
  end
end
