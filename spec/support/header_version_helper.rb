module HeaderVersionHelper

  # Set header for api requiest.
  # version - An Integer for indicate version number.
  # This returns a hash
  def api_header(version)
    if version >= 3
      {'HTTP_ACCEPT' => "application/vnd.commandp.v#{version}+json"}
    else
      {'HTTP_ACCEPT' => "application/commandp.v#{version}"}
    end
  end

end
