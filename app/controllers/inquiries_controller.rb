class InquiriesController < ApplicationController
  def new
    @inquiry = Inquiry.new
  end

  def confirm
    @inquiry = Inquiry.new(inquiry_params)
    if @inquiry.invalid?
      render :new, status: :unprocessable_entity
    end
  end

  def create
    @inquiry = Inquiry.new(inquiry_params)

    if params[:back] || !@inquiry.save
      render :new, status: :unprocessable_entity
    else
      redirect_to done_inquiries_path
    end
  end

  def done; end

  private

    def inquiry_params
      params.require(:inquiry).permit(:name, :email, :message)
    end
end
