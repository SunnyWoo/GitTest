module Print::ImpositionsHelper
  def render_imposition_form(imposition)
    base_name = @imposition.class.name.demodulize.underscore
    render "#{base_name}_form", imposition: imposition
  end

  def imposition_form_path(imposition)
    print_product_model_imposition_path(imposition.product)
  end

  def print_imposition_info(imposition)
    imposition.try(:info) || '(無拼版資訊)'
  end
end
