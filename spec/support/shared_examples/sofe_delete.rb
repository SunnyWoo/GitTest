shared_examples_for 'soft_delete' do
  it { is_expected.to respond_to(:really_delete) }
  it { is_expected.to respond_to(:restore) }

  context '#soft delete' do
    Given(:record) { create described_class.name.tableize.singularize.to_sym }
    Given(:record_id) { record.id }
    When { record.delete }
    Then { !record.deleted_at.nil? }
    And { described_class.all.pluck(:id).include?(record_id) == false }
  end
end
