namespace :shipping_fee do
  desc 'import shipping_fee'
  task import: :environment do
    ImportShippingFeeService.import
  end
end
