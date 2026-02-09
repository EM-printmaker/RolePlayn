require 'rails_helper'

RSpec.describe "Notifications", type: :request do
  describe "POST /notifications/read" do
    let(:user) { create(:user, unread_notification: true) }

    before do
      sign_in user
    end

    it "通知フラグをfalseに更新し、turbo_streamレスポンスを返すこと" do
        expect {
          post read_notifications_path, as: :turbo_stream
        }.to change(user, :unread_notification).from(true).to(false)

        expect(response).to have_http_status(:success)
        expect(response.media_type).to eq "text/vnd.turbo-stream.html"
      end
  end
end
