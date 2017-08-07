module WorkFinder
  private

  def find_work_or_archived_work
    @work = case
            when params[:work_id]
              Work.find(params[:work_id])
            when params[:archived_work_id]
              ArchivedWork.find(params[:archived_work_id])
            end
  end
end
