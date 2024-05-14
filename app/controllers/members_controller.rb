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
