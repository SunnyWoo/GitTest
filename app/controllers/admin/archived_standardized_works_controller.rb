class Admin::ArchivedStandardizedWorksController < ApplicationController
  before_action :find_standardized_work

  def create
    @standardized_work.create_archive
    render 'admin/standardized_works/update_list_item'
  end

  private

  def find_standardized_work
    @standardized_work = StandardizedWork.find(params[:standardized_work_id])
  end
end
