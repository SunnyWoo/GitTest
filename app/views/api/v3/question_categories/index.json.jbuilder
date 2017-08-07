json.cache! [cache_key_for_collection(@question_categories)] do
  json.question_categories do
    json.partial! 'api/v3/question_category', collection: @question_categories, as: :question_category
  end
end
