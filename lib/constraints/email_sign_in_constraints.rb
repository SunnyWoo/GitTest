class Constraints::EmailSignInConstraints

  def initialize(options)
    @way = options[:way]
    @default = options[:default]
  end

  def matches?(req)
    @default || req.params[:way] == "normal"
  end

end
