class InquiriesController < ApplicationController
  def new
    @inquiry = Inquiry.new
    if user_signed_in?
      @inquiry.name = current_user.login_id
      @inquiry.email = current_user.email
    end
  end

  def confirm
    @inquiry = Inquiry.new(inquiry_params)
    @inquiry.user = current_user if user_signed_in?
    if @inquiry.invalid?
      render :new, status: :unprocessable_entity
    end
  end

  def create
    @inquiry = Inquiry.new(inquiry_params)
    @inquiry.user = current_user if user_signed_in?

    if params[:back] || !@inquiry.save
      render :new, status: :unprocessable_entity
    else
      redirect_to done_inquiries_path
    end
  end

  def done; end

  private

    def inquiry_params
      params.require(:inquiry).permit(:name, :email, :message, :category)
    end
end
