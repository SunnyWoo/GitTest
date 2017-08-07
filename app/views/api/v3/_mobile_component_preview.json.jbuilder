json.call(component, :key, :position)
json.partial! "api/v3/mobile_components/#{component.key}", component: component
