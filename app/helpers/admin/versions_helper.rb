module Admin::VersionsHelper
  def render_version_author(version)
    version.admin.try(:email) || "whodunnit: #{version.whodunnit}"
  end

  def link_to_versions(model, options = {})
    link_to t('shared.versions'), [:admin, model, :versions], options
  end
end
