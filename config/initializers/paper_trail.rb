module VersionBelongsToAdmin
  extend ActiveSupport::Concern

  included do
    belongs_to :admin, foreign_key: 'whodunnit', class_name: 'Admin'
  end
end

PaperTrail::Version.send(:include, VersionBelongsToAdmin)
