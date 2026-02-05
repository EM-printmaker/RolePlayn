require 'rails_helper'

RSpec.describe "Inquiries", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get inquiries_new_path
      expect(response).to have_http_status(:success)
    end
  end
end
