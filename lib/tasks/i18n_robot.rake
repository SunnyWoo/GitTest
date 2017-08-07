namespace :i18n_robot do
  desc "save_i18n_from_yml_to_redis"
  task save_i18n_from_yml_to_redis: :environment do
    I18nBackendService.save_from_yml_to_redis
  end

  desc "delete_i18n_from_redis"
  task delete_i18n_from_redis: :environment do
    I18nBackendService.delete_i18n_from_redis
  end

  desc "save_i18n_from_redis_to_db"
  task save_i18n_from_redis_to_db: :environment do
    I18nBackendService.save_from_redis_to_db
  end
end
