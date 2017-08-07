class AddAwsArnToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :endpoint_arn, :string
  end
end