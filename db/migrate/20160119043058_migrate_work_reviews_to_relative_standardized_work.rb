class MigrateWorkReviewsToRelativeStandardizedWork < ActiveRecord::Migration
  def change
    StandardizedWork.find_each do |sw|
      work = Work.includes(:reviews).find_by(uuid: sw.uuid)
      next unless work
      work.reviews.each do |review|
        sw.reviews.create body: review.body, star: review.star
      end
    end
  end
end
