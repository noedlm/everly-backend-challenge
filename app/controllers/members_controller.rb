class MembersController < ApplicationController
  def index
    @members = Member.all
  end

  def show
    @member = Member.find(params[:id])
  end

  def new
    @member = Member.new(name: params.dig(:member, :name), full_url: params.dig(:member, :full_url))
  end

  def create
    @member = Member.new(member_params)
    # TODO: Use bitly instead of tinyurl, bitly requires additional setup
    @member.short_url = ShortURL.shorten(member_params[:full_url])

    if @member.save
        redirect_to @member
    else
        render 'new'
    end
  end

  private

  def member_params
    params.require(:member).permit(:name, :full_url)
  end
end
