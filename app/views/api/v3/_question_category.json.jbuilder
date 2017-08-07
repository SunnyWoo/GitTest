cache_json_for json, question_category do
  json.extract!(question_category, :id, :name)
  json.questions do
    json.array! question_category.questions do |question|
      json.extract!(question, :id, :question, :answer)
    end
  end
end
