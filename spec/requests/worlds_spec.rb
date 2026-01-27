require 'rails_helper'

RSpec.describe "Worlds", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/worlds/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/worlds/show"
      expect(response).to have_http_status(:success)
    end
  end

end
