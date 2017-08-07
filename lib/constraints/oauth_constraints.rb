class Constraints::OauthConstraints

  def initialize(options)
    @way = options[:way]
    @default = options[:default]
  end

  def matches?(req)
    @default || req.params[:way] == "oauth"
  end

end
