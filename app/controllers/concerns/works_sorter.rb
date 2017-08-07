module WorksSorter
  def sorted_works(sort, works)
    case sort
    when 'new'     then works.order('created_at DESC')
    when 'random'  then works.order('RANDOM()')
    when 'popular' then works.order('impressions_count DESC')
    else works.order('created_at DESC')
    end
  end
end
