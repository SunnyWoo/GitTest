class Admin::ResourcesController < AdminController
  attr_accessor :model_relations
  helper_method :model_class, :member, :model_name, :new_member_path, :collection_path

  def index
    @search = model_class.ransack(params[:q])
    @resources = @search.result(distinct: true).page(params[:page] || 1)
  end

  def new
    @resource = model_class.new(params[:attributes])
    log_with_current_admin @resource
  end

  def show
    @resource = model_class.find(params[:id])
    log_with_current_admin @resource
  end

  def edit
    @resource = model_class.find(params[:id])
    log_with_current_admin @resource
  end

  def update
    @resource = model_class.find(params[:id])
    log_with_current_admin @resource
    if @resource.update_attributes(admin_permitted_params.send(model_name.underscore))
      if params[:redirect_to_path]
        redirect_to URI.parse(params[:redirect_to_path]).path
      else
        flash[:notice] = "#{model_name} (#{@resource.class.primary_key} = #{@resource.to_param}) 更新成功!"
        redirect_to action: :index
      end
    else
      render action: :edit
    end
  end

  def create
    @resource = model_class.new(admin_permitted_params.send(model_name.underscore))
    log_with_current_admin @resource
    if @resource.save
      redirect_to collection_path
    else
      render action: :new
    end
  end

  def destroy
    model_class.find(params[:id]).destroy
    redirect_to :back
  end

  protected

  def new_member_path
    send "new_#{self.class.to_s.gsub('Controller', '').underscore.gsub('/', '_').singularize}_path".to_sym
  end

  def collection_path
    send("#{self.class.to_s.gsub('Controller', '').underscore.gsub('/', '_')}_path")
  end

  def model_class
    self.class.to_s.gsub('Controller', '').demodulize.classify.constantize
  end

  def model_name
    self.class.to_s.gsub('Controller', '').demodulize.classify
  end

  def member
    @resource
  end
end
