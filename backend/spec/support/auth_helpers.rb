module AuthHelpers
  def auth_headers(user)
    token = user.generate_jwt
    { "Authorization" => "Bearer #{token}" }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
