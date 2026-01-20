require 'rails_helper'

RSpec.describe "Tops", type: :request do
  describe "GET /index" do
    it "レスポンスが成功すること" do
      get root_path
      expect(response).to have_http_status(:success)
    end
  end
end
