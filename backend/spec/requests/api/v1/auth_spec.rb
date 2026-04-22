require 'rails_helper'

RSpec.describe "Api::V1::Auth", type: :request do
  describe "POST /api/v1/auth/register" do
    let(:valid_params) do
      {
        email: "alice@example.com",
        username: "alice",
        password: "password123",
        password_confirmation: "password123"
      }
    end

    it "creates a user and returns token" do
      post "/api/v1/auth/register", params: valid_params
      expect(response).to have_http_status(:created)
      json = response.parsed_body
      expect(json["user"]["email"]).to eq("alice@example.com")
      expect(json["token"]).to be_present
    end

    it "returns errors for invalid params" do
      post "/api/v1/auth/register", params: { email: "", username: "", password: "x" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["errors"]).to be_present
    end

    it "returns error for duplicate email" do
      create(:user, email: "alice@example.com")
      post "/api/v1/auth/register", params: valid_params
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "POST /api/v1/auth/login" do
    let!(:user) { create(:user, email: "alice@example.com", password: "password123") }

    it "returns token for valid credentials" do
      post "/api/v1/auth/login", params: { email: "alice@example.com", password: "password123" }
      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json["token"]).to be_present
      expect(json["user"]["email"]).to eq("alice@example.com")
    end

    it "rejects wrong password" do
      post "/api/v1/auth/login", params: { email: "alice@example.com", password: "wrong" }
      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to be_present
    end

    it "rejects unknown email" do
      post "/api/v1/auth/login", params: { email: "nobody@example.com", password: "password123" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/auth/me" do
    let!(:user) { create(:user) }

    it "returns current user when authenticated" do
      get "/api/v1/auth/me", headers: auth_headers(user)
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["user"]["id"]).to eq(user.id)
    end

    it "returns 401 without token" do
      get "/api/v1/auth/me"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 with invalid token" do
      get "/api/v1/auth/me", headers: { "Authorization" => "Bearer bad.token.here" }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
