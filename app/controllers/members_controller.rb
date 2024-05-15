class MembersController < ApplicationController
  def index
    @members = Member.all

    respond_to do |format|
      format.html
      format.json { render json: @members }
    end
  end

  def show
    @member = Member.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @member }
    end
  end

  def new
    @member = Member.new(first_name: params.dig(:member, :first_name), last_name: params.dig(:member, :last_name), url: params.dig(:member, :url))
  end

  def create
    @member = Member.new(member_params)
    # TODO: Use bitly instead of tinyurl, bitly requires additional setup
    # TODO: Maybe move this to the model?
    @member.short_url = ShortURL.shorten(member_params[:url]) if member_params[:url].present?

    if @member.save
      respond_to do |format|
        format.html { redirect_to @member }
        format.json { render json: @member, status: :ok }
      end
    else
      respond_to do |format|
        format.html { render 'new' }
        format.json { render json: @member.errors, status: :bad_request }
      end
    end
  end

  private

  def member_params
    params.fetch(:member, {}).permit(:first_name, :last_name, :url)
  end
end
