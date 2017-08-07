class SetAllProductModelToAssociateWithDefaultFactoryCommandp < ActiveRecord::Migration
  def change
    ProductModel.all.each do |pr|
      factory = Factory.find_by(username: "commandp") || Factory.create(username: "commandp",
                                                                         email: "dev@commandp.com",
                                                                         password: "commandp",
                                                                         password_confirmation: "commandp")
      pr.factories << factory
    end
  end
end
