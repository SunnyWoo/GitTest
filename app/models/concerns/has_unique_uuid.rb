module HasUniqueUUID
  extend ActiveSupport::Concern

  included do
    attr_readonly :uuid

    validates :uuid, uniqueness: true,
                     presence: true,
                     format: {
                       with: /\A[\da-f]{8}-[\da-f]{4}-[\da-f]{4}-[\da-f]{4}-[\da-f]{12}\z/i,
                       message: 'UUID format is invalid.'
                     },
                     on: :create
    before_validation :generate_uuid, unless: :uuid?
  end

  def generate_uuid
    self.uuid = UUIDTools::UUID.timestamp_create.to_s
  end
end
