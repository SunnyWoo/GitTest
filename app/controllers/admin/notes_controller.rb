class Admin::NotesController < AdminController
  before_action :find_noteable
  helper_method :model_class, :model_id, :class_name

  def index
    @notes = @noteable.notes
  end

  def new
    @note = @noteable.notes.build
  end

  def create
    @note = @noteable.notes.build(admin_permitted_params.note)
    @note.user = current_admin
    @note.save
    respond_to do |format|
      format.html
      format.js
      format.json { render 'api/v3/notes/show' }
    end
  end

  def edit
    @note = @noteable.notes.find(params[:id])
    respond_to do |format|
      format.html
      format.js
      format.json { render 'api/v3/notes/show' }
    end
  end

  def update
    @note = @noteable.notes.find(params[:id])
    @note.update_attributes(admin_permitted_params.note)
    respond_to do |f|
      f.js
      f.json { render 'api/v3/notes/show' }
    end
  end

  def destroy
    @note = @noteable.notes.find(params[:id])
    @note.destroy if @note
  end

  private

  def find_noteable
    @noteable = model_class.find(model_id)
  end

  def model_class
    class_name.demodulize.classify.constantize
  end

  def model_id
    params["#{class_name.singularize}_id".to_sym]
  end

  def class_name
    request.fullpath.match(/\/admin\/[a-z_]+/).to_s.gsub('/admin/', '')
  end
end
