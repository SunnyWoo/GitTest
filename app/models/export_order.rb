# == Schema Information
#
# Table name: export_orders
#
#  id         :integer          not null, primary key
#  file       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class ExportOrder < ActiveRecord::Base
  mount_uploader :file, DeliveryFileUploader

  def self.generate_export(day)
    start_date = Time.zone.parse(day).beginning_of_day
    end_date = start_date.end_of_day
    exporter = Guanyi::ExportOrders.new(start_date, end_date)
    export_order = ExportOrder.new
    exporter.generate_zip do |zip_file|
      export_order.file = File.open(zip_file)
      export_order.save!
    end
    export_order
  end
end
