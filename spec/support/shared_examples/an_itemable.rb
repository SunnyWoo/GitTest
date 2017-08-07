shared_examples_for 'an itemable' do
  it { is_expected.to be_kind_of(HasUniqueUUID) }

  it { is_expected.to respond_to(:slug) }
  it { is_expected.to respond_to(:slug=) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to respond_to(:user_avatar) }
  it { is_expected.to belong_to(:product).class_name('ProductModel') }
  it { is_expected.to have_many(:order_items) }
  it { is_expected.to respond_to(:user_display_name) }
  it { is_expected.to respond_to(:product_name) }
  it { is_expected.to respond_to(:product_description) }
  it { is_expected.to respond_to(:product_width) }
  it { is_expected.to respond_to(:product_height) }
  it { is_expected.to respond_to(:product_dpi) }
  it { is_expected.to respond_to(:product_dpi_width) }
  it { is_expected.to respond_to(:product_dpi_height) }
  it { is_expected.to respond_to(:price_in_currency) }
  it { is_expected.to respond_to(:print_image) }
  it { is_expected.to respond_to(:has_special_price?) }
end
