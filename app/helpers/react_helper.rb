module ReactHelper
  def mount_react_app(name, props = {}, reducers = [])
    data = {
      react_app: name,
      react_app_props: props.to_json,
      react_app_reducers: reducers.to_json
    }
    content_tag(:div, '', data: data)
  end
end
