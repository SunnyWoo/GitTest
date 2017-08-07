case
when sub.contents.product_category_key.present?
  action_target = 'product_category'
  action_key = sub.contents.product_category_key
when sub.contents.product_model_key.present?
  action_target = 'product_model'
  action_key = sub.contents.product_model_key
else
  action_target = ''
  action_key = ''
end

json.action_type 'create'
json.action_target action_target
json.action_key action_key
