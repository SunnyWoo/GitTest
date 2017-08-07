# Delegates `attr` and `attr=` to the delegated object.
#
# Usage:
#
#     serialize :extra_info, ExtraInfo
#     # Generates:
#     # delegate :width, :width=, :height, :height=, to: :extra_info
#     delegate_accessors :width, :height, to: :extra_info
module DelegateAccessors
  extend ActiveSupport::Concern

  module ClassMethods
    def delegate_accessors(*attrs, options)
      attrs_accessors = attrs.each_with_object([]) do |attr, array|
        array << attr << :"#{attr}="
      end

      delegate(*attrs_accessors, options)
    end
  end
end
