cache_json_for json, @work do
  json.related_works do
    json.series_works do
      json.partial! 'api/v3/work', collection: @work.series_works(params[:series_count]), as: :work
    end
    json.designer_works do
      json.partial! 'api/v3/work', collection: @work.designer_works(params[:designer_count]), as: :work
    end
    json.recommend_works do
      json.partial! 'api/v3/work', collection: @work.recommend_works(params[:recommend_count]), as: :work
    end
  end
  json.meta do
    json.series_count @work.series_works(params[:series_count]).count
    json.designer_count @work.designer_works(params[:designer_count]).count
    json.recommend_count @work.recommend_works(params[:recommend_count]).count
  end
end
