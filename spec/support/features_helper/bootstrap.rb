shared_context 'bootstarp', type: :feature do
  before do
    # 建立 iPhone 6 model
    model = create(:product_model, name: 'iPhone 6', price_table: {'USD' => 99.9, 'TWD' => 900})
  end
end
