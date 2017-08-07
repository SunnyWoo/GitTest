# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone

Mime::Type.unregister :json
Mime::Type.register 'application/xlsx', :xlsx
Mime::Type.register 'application/json', :json, %w(
  text/x-json
  application/jsonrequest
  application/commandp.v1
  application/commandp.v2
  application/vnd.commandp.v1
  application/vnd.commandp.v2
  application/vnd.commandp.v3+json
)

Mime::Type.register 'application/octet-stream', :protobuf, %w(application/vnd.commandp.v3+protobuf)
