namespace :coupon do
  desc 'Dump coupon codes into csv format'
  task :codes, %i(id) => :environment do |_t, args|
    coupon = Coupon.find args.id
    column_titles = %w(code)
    res = CSV.generate do |csv|
      csv << column_titles
      coupon.children.each do |child_coupon|
        csv << [sprintf('="%s"', child_coupon.code)]
      end
    end
    puts res
  end

  desc 'Generate coupon children'
  task :generate_children, %i(id number) => :environment do |_t, args|
    coupon = Coupon.find args.id
    args.number.to_i.times do
      coupon.children.create(coupon.send(:child_attributes).merge(usage_count_limit: 1))
    end
  end

  desc 'Fallback coupon, When coupon expired remove order coupon .'
  task fallback: :environment do
    Coupon.fallback_expired_coupon_orders
  end
end

