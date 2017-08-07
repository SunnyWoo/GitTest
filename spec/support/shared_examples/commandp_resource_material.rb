shared_examples_for 'commandp_resource_material' do
  context '#commandp_resource_material' do
    context 'with commandp_resource supported type layer' do
      Given(:layer_type) { Layer.layer_types[Layer::COMMANDP_RESOURCE_TYPES.sample] }
      Given(:layer) { build :layer, layer_type: layer_type }
      context 'commandp_resource_material does exist when material_name is included in CommandP::Resources[:layer_types]' do
        Given(:material_name) { CommandP::Resources.send(layer.layer_type.pluralize).send(:mapping).keys.sample }
        When { layer.material_name = material_name }
        Then { layer.valid? }
        And { layer.commandp_resource_material.present? }
      end

      context 'commandp_resource_material does not exist when material_name is not included in CommandP::Resources[:layer_types]' do
        When { layer }
        Then { layer.invalid? }
        And { layer.commandp_resource_material.blank? }
      end
    end

    context 'commandp_resource_material should be blank with commandp_resource upsupported type layer' do
      Given(:layer_type) { (Layer.layer_types.keys - Layer::COMMANDP_RESOURCE_TYPES).sample }
      Given(:layer) { create :layer }
      When { layer }
      Then { expect(layer.commandp_resource_material).to be_blank }
    end
  end
end
