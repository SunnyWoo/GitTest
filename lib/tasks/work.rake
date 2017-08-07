namespace :work do
  task migrate_from_user_to_designer: :environment do
    User.designer.each do |user|
      username = user.email.split('@').first
      password = SecureRandom.urlsafe_base64
      designer = Designer.create!(username: username,
                                  email: user.email,
                                  display_name: user.username || username,
                                  password: password,
                                  password_confirmation: password,
                                  remote_avatar_url: user.avatar.url)
      user.works.each do |work|
        work.update(user: designer)
      end
    end
  end

  # 建立Fake Work 可以在自訂圖片
  task create_fake: :environment do
    user = User.new_guest
    url = "https://api.500px.com/v1/photos?feature=popular&image_size=5&consumer_key=CLmpqnpwGLKetORtjc5gb9tC2hllfd6cqdfzHqFD"
    res = HTTParty.get(url)
    names = res['photos'].map{ |p| p['name'] }
    images = res['photos'].map{ |p| p['images'][0]['url'] }
    ProductModel.available.each do |model|
      spec = model.specs.first
      Work.create do |s|
        s.name = names[0]
        s.model = model
        s.spec = spec
        s.work_type = 'is_public'
        s.user = user
        s.uuid = UUIDTools::UUID.timestamp_create.to_s
        s.remote_print_image_url = images[0]
        names.delete_at(0)
        images.delete_at(0)
      end
    end
  end

  # before run sidekiq
  # vim /app/models/work.rb
  # 註解 line: 78 # after_commit :enqueue_build_previews
  # 不然會 enqueue_build_previews 感覺很恐怖！！

  # # run sidekiq
  # RAILS_ENV=staging bundle exec sidekiq -q low -c 5
  # RAILS_ENV=production_ready bundle exec sidekiq -q low -c 5
  # RAILS_ENV=production bundle exec sidekiq -q low -c 5

  # REGION=china RAILS_ENV=staging bundle exec sidekiq -q low -c 5
  # REGION=china RAILS_ENV=production_ready bundle exec sidekiq -q low -c 5
  # REGION=china RAILS_ENV=production bundle exec sidekiq -q low -c 5
  desc "Recreate version print_image thumb"
  task print_upload_recreate_versions: :environment do
    Work.where('print_image is not null').find_each do |work|
      PrintUploaderRecreateThumbWorker.perform_async(work.to_gid_param, :print_image)
    end

    ArchivedWork.where('print_image is not null').find_each do |work|
      PrintUploaderRecreateThumbWorker.perform_async(work.to_gid_param, :print_image)
    end

    StandardizedWork.where('print_image is not null').find_each do |work|
      if work.print_image.model.is_a?(StandardizedWork)
        PrintUploaderRecreateThumbWorker.perform_async(work.to_gid_param, :print_image)
      end
    end

    ArchivedStandardizedWork.where('print_image is not null').find_each do |work|
      if work.print_image.model.is_a?(StandardizedWork)
        PrintUploaderRecreateThumbWorker.perform_async(work.to_gid_param, :print_image)
      end
    end

    WorkOutputFile.where(key: 'print-image').where('file is not null').find_each do |work|
      PrintUploaderRecreateThumbWorker.perform_async(work.to_gid_param, :file)
    end
  end

  task associate_variant: :environment do
    ProductModel.find_each do |product|
      variant_id = product.variants.first.try(:id)

      # update work
      Work.where(model_id: product.id).update_all(variant_id: variant_id)

      # update archived_work
      ArchivedWork.where(model_id: product.id).update_all(variant_id: variant_id)

      # update standardized_work
      StandardizedWork.where(model_id: product.id).update_all(variant_id: variant_id)

      # update archived_standardized_work
      ArchivedStandardizedWork.where(model_id: product.id).update_all(variant_id: variant_id)
    end
  end
end
