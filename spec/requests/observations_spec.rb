require 'rails_helper'

RSpec.describe "Observations", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/observations/show"
      expect(response).to have_http_status(:success)
    end
  end

end
