module Admin::WorksHelper
  def render_admin_itemable_path(itemable)
    if itemable.is_a? ArchivedStandardizedWork
      url_for([:edit, :admin, itemable.original_work]) if itemable.original_work.present?
    else
      url_for([:admin, itemable])
    end
  end

  def render_standardized_work_editor(work)
    react_component 'CPA.StandardizedWorkEditor.App', work_id: work.id
  end

  def render_admin_standardized_work_build_previews_button(work)
    return if work.build_previews
    url = admin_standardized_work_path(work, work: { build_previews: true })
    options = { class: 'btn btn-default btn-minier', remote: true, method: :patch }
    link_to t('shared.form_actions.build_previews'), url, options
  end

  def render_admin_standardized_work_build_print_image_button(work)
    return if work.is_build_print_image
    url = admin_standardized_work_path(work, work: { is_build_print_image: true })
    options = { class: 'btn btn-default btn-minier', remote: true, method: :patch }
    link_to t('shared.form_actions.build_print_image'), url, options
  end

  def render_admin_standardized_state_button(work)
    case work.aasm_state
    when 'draft', 'pulled'
      render_publish_admin_standardized_button(work)
    when 'published'
      render_pull_admin_standardized_button(work)
    end
  end

  def render_publish_admin_standardized_button(work)
    url = publish_admin_standardized_work_path(work)
    options = { class: 'btn btn-default btn-minier', remote: true, method: :post }
    link_to t('shared.form_actions.go_publish'), url, options
  end

  def render_pull_admin_standardized_button(work)
    url = pull_admin_standardized_work_path(work)
    options = { class: 'btn btn-danger btn-minier', remote: true, method: :post }
    link_to t('shared.form_actions.go_pull'), url, options
  end

  def render_create_archived_standardized_work_button(work)
    # 有封存過 且 最近封存的時間比作品更新還晚 就不顯示按鈕
    return if work.archives.any? && work.updated_at < work.archives.first.created_at
    url = admin_standardized_work_archives_path(work)
    options = { class: 'btn btn-info btn-minier', remote: true, method: :post }
    link_to t('shared.form_actions.archive'), url, options
  end

  def render_standardized_work_archive_state(work)
    key = case
          when work.archives.empty?                             then 'none'
          when work.updated_at > work.archives.first.created_at then 'stale'
          else                                                       'fresh'
          end
    t(key, scope: 'works.archive_state')
  end
end
