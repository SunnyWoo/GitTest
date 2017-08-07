class ApiConstraints

  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(req)
    @default || req.headers['Accept'] =~ %r{application/(?:vnd.)?commandp.v#{@version}}
  end

end
