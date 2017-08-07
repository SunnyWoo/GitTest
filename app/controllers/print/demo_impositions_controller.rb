class Print::DemoImpositionsController < PrintController
  include ImpositionFinder

  before_action :find_model
  before_action :find_imposition_class

  def create
    @imposition = @imposition_class.demo.new(model: @model)
    if @imposition.update(imposition_params)
      Imposition::DemoBuilder.perform_async(@imposition.id, current_factory_member.email)
      render json: @imposition
    else
      render json: @imposition.error, status: :unprocessed_entity
    end
  end
end
