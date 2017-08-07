require 'seed-fu'

SiteSetting.seed_once(:key) do |s|
  s.key = 'iOSVersion'
  s.value = '1.0.2'
  s.description = 'iOS 最小版號要求，低於此版號將進行強制更新'
end

SiteSetting.seed_once(:key) do |s|
  s.key = 'AndroidVersion'
  s.value = '1.0.0'
  s.description = 'Android 最小版號要求，低於此版號將進行強制更新'
end

SiteSetting.seed_once(:key) do |s|
  s.key = 'iOSRNVersion'
  s.value = '1.0.0'
  s.description = 'iOS 上 RN 的最新版號'
end

SiteSetting.seed_once(:key) do |s|
  s.key = 'iOSMinContainerVersion'
  s.value = '1.0.0'
  s.description = 'iOS 上 RN 的最小版號，低於此版號將進行強制更新'
end

SiteSetting.seed_once(:key) do |s|
  s.key = 'AndroidMinContainerVersion'
  s.value = '1.0.0'
  s.description = 'Android 上 RN 的最小版號，低於此版號將進行強制更新'
end

SiteSetting.seed_once(:key) do |s|
  s.key = 'iOSRNBundleURL'
  if Region.china?
    s.value = Settings.SiteSettings.CN.iOSRNBundleURL
  else
    s.value = Settings.SiteSettings.Global.iOSRNBundleURL
  end
  s.description = 'iOS RN Bundle 路徑'
end

SiteSetting.seed_once(:key) do |s|
  s.key = 'AndroidRNBundleURL'
  if Region.china?
    s.value = Settings.SiteSettings.CN.AndroidRNBundleURL
  else
    s.value = Settings.SiteSettings.Global.AndroidRNBundleURL
  end
  s.description = 'Android RN Bundle 路徑'
end
