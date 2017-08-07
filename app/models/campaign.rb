# == Schema Information
#
# Table name: campaigns
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  key                :string(255)
#  title              :string(255)
#  desc               :string(255)
#  designer_username  :string(255)
#  artworks_class     :string(255)
#  wordings           :json
#  about_designer     :text
#  created_at         :datetime
#  updated_at         :datetime
#  aasm_state         :string(255)      default("is_closed")
#  google_calendar_id :string(255)
#

class Campaign < ActiveRecord::Base
  strip_attributes only: %i(name key title desc designer_username)
  include AASM
  include HasGoogleCalendar
  serialize :wordings, Hashie::Mash.pg_json_serializer

  has_many :campaign_images
  accepts_nested_attributes_for :campaign_images, allow_destroy: true

  validates :name, :key, :title, presence: true
  validates :key, uniqueness: true

  after_save :enqueue_google_calendar_event, on: [:create, :update], if: :enable_google_calendar?
  after_destroy :enqueue_delete_google_calendar_event, if: :enable_google_calendar?

  ARTWORK_CLASS = { column2: 'grid_3 camp_artworks', column3: 'grid_2 camp_artworks2' }.freeze

  WORDING_KEYS = { campaign_head: :string, gift_title: :string, gift_name: :string,
                   gift_desc: :text, gift_starts_at: :string, gift_ends_at: :string,
                   gift_plean_title: :string, gift_mode_desc: :text, artwork_title: :string,
                   instagram_htag: :string, instagram_desc: :text, gift_line: :boolean,
                   hide_product: :boolean, artwork_first: :boolean, show_instagram: :boolean }.freeze

  aasm do
    state :is_preparing
    state :is_published
    state :is_closed, initial: true

    event :prepare do
      transitions from: [:is_published, :is_closed], to: :is_preparing
    end

    event :publish do
      transitions from: [:is_preparing, :is_closed], to: :is_published
    end

    event :close do
      transitions from: [:is_published, :is_preparing], to: :is_closed
    end
  end

  def render_about_designer
    Campaign::ARTWORK_CLASS
  end

  def head_key
    "head_#{key}"
  end

  def g_start_at
    wordings['gift_starts_at'] == "" ? created_at.strftime("%Y-%m-%d") : wordings['gift_starts_at']
  end

  def g_end_at
    wordings['gift_ends_at'] == "" ? (created_at + 1.day).strftime("%Y-%m-%d") : wordings['gift_ends_at']
  end

  private

  def enqueue_google_calendar_event
    GoogleCalendarCampaignEventWorker.perform_async(id)
  end

  def enqueue_delete_google_calendar_event
    GoogleCalendarDeleteEventWorker.perform_async(google_calendar_id) unless google_calendar_id.nil?
  end
end
