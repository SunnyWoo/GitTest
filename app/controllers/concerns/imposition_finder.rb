module ImpositionFinder
  private

  def find_model
    @model = ProductModel.find(params[:product_model_id])
  end

  def find_imposition_class
    @imposition_class = Imposition.const_get(params[:type])
  end

  def imposition_params
    params.require(:imposition).permit(*@imposition.available_params)
  end
end
