crumb :root do
  link 'Home', root_path
end

crumb :admin do
  link 'Admin', admin_root_path
end

crumb :admin_site_settings do
  link t('site_settings.sidebar_name'), admin_site_settings_path
  parent :admin
end

crumb :admin_accounts do
  link t('account.sidebar_name')
  parent :admin
end

crumb :admin_users do
  link t('users.sidebar_name'), admin_users_path
  parent :admin_accounts
end

crumb :admin_admins do
  link t('admins.sidebar_name'), admin_admins_path
  parent :admin_accounts
end

crumb :admin_designers do
  link t('designers.sidebar_name'), admin_designers_path
  parent :admin_accounts
end

crumb :admin_activities do
  link t('activities.sidebar_name'), admin_activities_path
  parent :admin
end

crumb :admin_works do
  link t('works.sidebar_name'), admin_works_path
  parent :admin
end

crumb :admin_work do |work|
  if work
    link work.name, admin_work_path(work)
  else
    link '(deleted)'
  end
  parent :admin_works
end

crumb :edit_admin_work do |work|
  link t('works.edit.page_title.edit', name: work.name), edit_admin_work_path(work)
  parent :admin_work, work
end

crumb :admin_work_sets do
  link t('work_sets.sidebar_name'), admin_work_sets_path
  parent :admin_works
end

crumb :admin_tags do
  link t('admin.v2.shared.sidebar.tags'), admin_tags_path
  parent :admin_works
end

crumb :new_admin_tags do
  link t('tags.new.page_title')
  parent :admin_works
end

crumb :edit_admin_tags do
  link t('tags.edit.page_title')
  parent :admin_works
end

crumb :admin_tag_works do |tag_name|
  link tag_name
  parent :admin_tags
end

crumb :admin_archived_works do
  link t('archived_works.sidebar_name'), admin_archived_works_path
  parent :admin_works
end

crumb :admin_archived_work do |work|
  link work.name, admin_archived_work_path(work)
  parent :admin_work, work.original_work
end

crumb :edit_admin_archived_work do |work|
  link t('works.edit.page_title.edit', name: work.name), edit_admin_archived_work_path(work)
  parent :admin_archived_work, work
end

crumb :admin_fees do
  link t('fees.sidebar_name'), admin_fees_path
  parent :admin
end

crumb :admin_orders do
  link t('orders.sidebar_name')
  parent :admin
end

crumb :admin_orders_list do
  link t('orders.sidebar_name_list'), admin_orders_path
  parent :admin_orders
end

crumb :admin_unapproved_orders do
  link t('orders.sidebar_name_approve'), unapproved_admin_orders_path
  parent :admin_orders
end

crumb :admin_notifications do
  link t('notifications.sidebar_name'), admin_notifications_path
  parent :admin
end

crumb :new_admin_notification do
  link t('notifications.publish'), admin_notifications_path
  parent :admin_notifications
end

crumb :report_admin_notification do
  link t('notifications.report'), admin_notifications_path
  parent :admin_notifications
end

crumb :admin_devices do
  link t('devices.sidebar_name'), admin_devices_path
  parent :admin_notifications
end

crumb :admin_newsletters do
  link t('newsletters.sidebar_name'), admin_newsletters_path
  parent :admin
end

crumb :new_admin_newsletters do
  link t('newsletters.new.page_title')
  parent :admin_newsletters
end

crumb :edit_admin_newsletters do
  link t('newsletters.edit.page_title')
  parent :admin_newsletters
end

crumb :admin_newsletter do
  link t('newsletters.show.page_title')
  parent :admin_newsletters
end

crumb :admin_newsletter_subscriptions do
  link t('newsletter_subscriptions.sidebar_name'), admin_newsletter_subscriptions_path
  parent :admin_newsletters
end

crumb :admin_campaigns do
  link t('campaigns.index.page_title'), admin_campaigns_path
  parent :admin
end

crumb :new_admin_campaigns do
  link t('campaigns.new.page_title')
  parent :admin_campaigns
end

crumb :edit_admin_campaigns do
  link t('campaigns.edit.page_title')
  parent :admin_campaigns
end

crumb :admin_bdevents do
  link t('bdevents.index.page_title'), admin_bdevents_path
  parent :admin
end

crumb :new_admin_bdevents do
  link t('bdevents.new.page_title')
  parent :admin_bdevents
end

crumb :edit_admin_bdevents do
  link t('bdevents.edit.page_title')
  parent :admin_bdevents
end

crumb :admin_masks do
  link t('masks.index.page_title'), admin_masks_path
  parent :admin
end

crumb :admin_masks_new do
  link t('masks.new.page_title')
  parent :admin_masks
end

crumb :product_models do
  link t('product_models.index.page_title'), admin_product_models_path
  parent :admin
end

crumb :product_models_import do
  link 'Import Product Model'
  parent :product_models
end

crumb :work_specs do |work_spec|
  link 'work_specs', edit_admin_product_model_work_spec_path(work_spec.model, work_spec)
  parent :product_models
end

crumb :admin_work_templates do |work_spec|
  link t('work_templates.index.page_title')
  parent :work_specs, work_spec
end

crumb :admin_work_templates_new do |work_spec|
  link t('work_templates.new.page_title')
  parent :admin_work_templates, work_spec
end

crumb :admin_work_templates_edit do |work_spec|
  link t('work_templates.edit.page_title')
  parent :admin_work_templates, work_spec
end

crumb :admin_mobile_campaigns do
  link 'Mobile Campaign', admin_mobile_campaigns_path
  parent :admin
end

crumb :new_admin_mobile_campaigns do
  link 'New Mobile Campaign'
  parent :admin_mobile_campaigns
end

crumb :edit_admin_mobile_campaigns do
  link 'Edit Mobile Campaign'
  parent :admin_mobile_campaigns
end

crumb :admin_mobile_pages do
  link 'Mobile Page', admin_mobile_pages_path
  parent :admin
end

crumb :new_admin_mobile_pages do
  link 'New Mobile Page'
  parent :admin_mobile_pages
end

crumb :edit_admin_mobile_pages do |mobile_page|
  link "Edit Mobile Page (#{mobile_page.title})", edit_admin_mobile_page_path(mobile_page)
  parent :admin_mobile_pages
end

crumb :edit_admin_mobile_components do |mobile_page|
  link 'Edit Mobile Component'
  parent :edit_admin_mobile_pages, mobile_page
end

crumb :admin_coupon_notices do
  link t('coupon_notices.index.page_title'), admin_coupon_notices_path
  parent :admin
end

crumb :admin_new_coupon_notices do
  link t('coupon_notices.new.page_title')
  parent :admin_coupon_notices
end

crumb :admin_edit_coupon_notices do
  link t('coupon_notices.edit.page_title')
  parent :admin_coupon_notices
end

crumb :admin_preview_coupon_notices do
  link t('coupon_notices.preview.page_title')
  parent :admin_coupon_notices
end

crumb :admin_collections do
  link t('collections.index.page_title'), admin_collections_path
  parent :admin
end

crumb :new_admin_collections do
  link t('collections.new.page_title')
  parent :admin_collections
end

crumb :edit_admin_collections do
  link t('collections.edit.page_title')
  parent :admin_collections
end

crumb :admin_collection_works do |collection_name|
  link collection_name
  parent :admin_collections
end

crumb :admin_coupons do
  link t('coupons.index.page_title'), admin_coupons_path
  parent :admin
end

crumb :admin_coupon_children do |coupon_name|
  link coupon_name
  parent :admin_coupons
end

crumb :admin_product_codes do
  link t('product_codes.sidebar_name')
  parent :admin
end

crumb :admin_material_codes do
  link t('channel_codes.manage'), admin_product_codes_path
  parent :admin_product_codes
end

crumb :admin_channel_codes do
  link t('channel_codes.manage'), admin_channel_codes_path
  parent :admin_product_codes
end

crumb :deliver_list do
  link t('deliver_order.index.page_title'), admin_deliver_orders_path
  parent :admin_orders
end

crumb :admin_factories do
  link t('factories.sidebar_name'), admin_factories_path
end

crumb :admin_factory_members do
  link t('factory_members.sidebar_name'), admin_factories_path
end

crumb :admin_recommend_sorts do
  link t('recommend_sorts.index.page_title'), admin_recommend_sorts_path
  parent :admin
end

crumb :edit_admin_recommend_sorts do
  link t('recommend_sorts.edit.page_title')
  parent :admin_recommend_sorts
end

crumb :admin_standardized_works do
  link t('standardized_works.index.page_title'), admin_standardized_works_path
  parent :admin
end

crumb :edit_admin_standardized_work do
  link t('standardized_works.edit.page_title')
  parent :admin_standardized_works
end

crumb :new_admin_standardized_work do
  link t('standardized_works.new.page_title')
  parent :admin_standardized_works
end

crumb :admin_promotions do
  link t('admin.v2.shared.sidebar.promotions'), admin_promotions_path
  parent :admin
end

crumb :new_admin_promotions do
  link t('promotions.new.page_title')
  parent :admin_promotions
end

crumb :edit_admin_promotions do
  link t('promotions.edit.page_title')
  parent :admin_promotions
end

crumb :show_admin_promotions do |name|
  link t('promotions.show.page_title', name: name)
  parent :admin_promotions
end

crumb :purchase_categories do
  link t('purchase_categories.index.page_title'), admin_purchase_categories_path
  parent :admin
end

crumb :new_purchase_category do
  link t('purchase_categories.index.page_title'), new_admin_purchase_category_path
  parent :admin
end

crumb :edit_purchase_category do
  link t('purchase_categories.index.page_title'), edit_admin_purchase_category_path
  parent :admin
end

crumb :purchase_durations do
  link t('durations.index.page_title'), admin_purchase_durations_path
  parent :admin
end

crumb :admin_change_price_events do
  link t('admin.v2.shared.sidebar.change_price_events'), admin_change_price_events_path
  parent :admin_works
end

crumb :new_admin_change_price_events do
  link t('change_price_events.new.page_title')
  parent :admin_works
end

crumb :admin_change_price_histories do
  link t('change_price_histories.index.page_title')
  parent :admin_change_price_events
end

crumb :admin_stores do
  link t('stores.sidebar_name'), admin_stores_path
  parent :admin_accounts
end

crumb :option_types do
  link t('option_types.index.page_title'), admin_option_types_path
  parent :admin
end

crumb :edit_option_type do |name|
  link t('option_types.edit.page_title', name: name)
  parent :option_types
end

crumb :option_type do |name|
  link t('option_types.show.page_title', name: name)
  parent :option_types
end

crumb :new_option_type do
  link t('option_types.new.page_title'), new_admin_option_type_path
  parent :option_types
end

crumb :variants do |product|
  link t('variants.index.page_title', product: product.name), admin_product_model_variants_path(product)
  parent :product_models
end

crumb :new_variant do |product|
  link t('variants.new.page_title', product: product.name), new_admin_product_model_variant_path(product)
  parent :variants, product
end

crumb :edit_variant do |product, variant|
  link t('variants.edit.page_title', product: product.name), edit_admin_product_model_variant_path(product, variant)
  parent :variants, product
end

crumb :cp_resources do
  link t('cp_resources.sidebar_name'), admin_cp_resources_path
  parent :admin
end

crumb :new_cp_resource do
  link t('cp_resources.new.page_title')
  parent :cp_resources
end

crumb :edit_cp_resource do |cp|
  link t('cp_resources.edit.page_title', version: cp.version)
  parent :cp_resources
end

crumb :store_backend do
  link '頁店後台', store_backend_root_path
end

crumb :store_backend_demos do
  link '開發用展示頁面'
  parent :store_backend
end

crumb :store_backend_demos_elements do
  link '元件展示', elements_store_backend_demos_path
  parent :store_backend_demos
end
