module ArchivedWorkFinder
  private

  def find_work
    @work = case
            when params[:work_id]
              Work.find(params[:work_id])
            when params[:archived_work_id]
              ArchivedWork.find(params[:archived_work_id])
            end
  end
end
