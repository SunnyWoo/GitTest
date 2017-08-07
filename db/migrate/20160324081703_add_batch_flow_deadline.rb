class AddBatchFlowDeadline < ActiveRecord::Migration
  def change
    add_column :batch_flows, :deadline, :datetime

    BatchFlow.find_each do |bf|
      bf.deadline = DateTime.strptime("#{bf.batch_no} +0800", "%Y%m%d-%H%M %z")
      bf.batch_no = bf.created_at.strftime("%Y%m%d-%H%M")
      bf.save
    end
  end
end
