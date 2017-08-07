class AddUuidToArchivedWorks < ActiveRecord::Migration
  def change
    add_column :archived_works, :uuid, :string

    ArchivedWork.find_each do |work|
      work.update(uuid: SecureRandom.uuid)
    end
  end

  class ArchivedWork < ActiveRecord::Base
  end
end
