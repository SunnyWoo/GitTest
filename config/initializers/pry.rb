Pry.config.prompt_name = Rails.application.class.parent_name.underscore.dasherize

unless Rails.env.development?
  old_prompt = Pry.config.prompt
  region = Pry::Helpers::Text.purple(Region.region.upcase)
  if Rails.env.production?
    env = "\001\e[0;31m\002#{Rails.env.upcase}\001\e[0m\002"
  else
    env = "\001\e[0;33m\002#{Rails.env.upcase}\001\e[0m\002"
  end
  Pry.config.prompt = [
    proc { |*a| "[#{region}] #{env} #{old_prompt.first.call(*a)}"  },
    proc { |*a| "[#{region}] #{env} #{old_prompt.second.call(*a)}" }
  ]
end
