json.omniauth do
  json.partial! 'api/v3/auth', auth: @omniauth
end
