require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_uniqueness_of(:username).case_insensitive }
    it { is_expected.to have_secure_password }

    it "is invalid without email" do
      user = build(:user, email: "")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "is invalid with a duplicate email" do
      create(:user, email: "taken@example.com")
      user = build(:user, email: "taken@example.com")
      expect(user).not_to be_valid
    end

    it "is invalid with a duplicate username" do
      create(:user, username: "takenname")
      user = build(:user, username: "takenname")
      expect(user).not_to be_valid
    end

    it "is invalid with password shorter than 6 characters" do
      user = build(:user, password: "12345", password_confirmation: "12345")
      expect(user).not_to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:videos).dependent(:destroy) }
  end

  describe "#generate_jwt" do
    it "returns a JWT string" do
      user = create(:user)
      token = user.generate_jwt
      expect(token).to be_a(String)
      expect(token.split(".").length).to eq(3)
    end
  end

  describe "#as_public_json" do
    it "does not include password_digest" do
      user = create(:user)
      json = user.as_public_json
      expect(json).not_to have_key(:password_digest)
      expect(json[:email]).to eq(user.email)
      expect(json[:username]).to eq(user.username)
    end
  end

  describe "email normalisation" do
    it "downcases email before saving" do
      user = create(:user, email: "Alice@EXAMPLE.COM")
      expect(user.reload.email).to eq("alice@example.com")
    end
  end
end
