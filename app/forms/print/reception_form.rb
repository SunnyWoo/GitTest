class Print::ReceptionForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_reader :item, :temp_shelf
  attr_accessor :state

  delegate :timestamp_no, to: :item
  delegate :serial, :description, to: :temp_shelf

  STATES = %w(received_on_temp_shelf received_only).freeze
  DEFAULT_STATE = 'received_on_temp_shelf'.freeze

  validates :state, inclusion: { in: STATES, message: '%{value} is not a valid state' }
  validates_presence_of :serial, if: :on_temp_shelf?

  class << self
    def model_name
      ActiveModel::Name.new(self, nil, 'reception')
    end
  end

  def initialize(print_item)
    @item = print_item
    @temp_shelf = print_item.temp_shelf || TempShelf.new
    @state = if @temp_shelf.persisted?
               'received_on_temp_shelf'
             elsif print_item.received?
               'received_only'
             else
               DEFAULT_STATE
             end
  end

  def attributes=(attrs)
    @state = attrs[:state]
    @temp_shelf.attributes = attrs.slice(:serial, :description)
  end

  def save
    if valid?
      @item.transaction do
        @item.receive! unless @item.sublimated?
        if on_temp_shelf?
          @temp_shelf.print_item ||= @item
          @temp_shelf.save!
        end
        true
      end
    end
  end

  def state_option
    STATES.map { |s| [I18n.t(s, scope: "simple_form.options.reception.state"), s] }
  end

  private

  def on_temp_shelf?
    @state == 'received_on_temp_shelf'
  end
end
