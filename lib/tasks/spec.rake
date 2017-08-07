if defined?(RSpec)
  namespace :spec do
    RSpec::Core::RakeTask.new(:unit) do |t|
      t.pattern = Dir['spec/*/**/*_spec.rb'].reject{ |f| f['/api/v1'] || f['/api/v2'] || f['/features'] }
    end

    RSpec::Core::RakeTask.new(:api) do |t|
      t.pattern = "spec/*/api/**/*_spec.rb"
    end

    RSpec::Core::RakeTask.new(:features) do |t|
      t.pattern = "spec/features/**/*_spec.rb"
    end
  end
end
