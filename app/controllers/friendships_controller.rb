class FriendshipsController < ApplicationController
  def new 
    @friendship = Friendship.new  
  end

  def create
    @member = Member.find_by(id: friendship_params[:member_id])
    @friendship = Friendship.new(friendship_params)

    if @friendship.save
      respond_to do |format|
        format.html { redirect_to @member }
        format.json { render json: @member, status: :ok }
      end
    else
      respond_to do |format|
        format.html { render 'new' }
        format.json { render json: @friendship.errors, status: :bad_request }
      end
    end
  end

  private

  def friendship_params
    params.fetch(:friendship, {}).permit(:member_id, :friend_id)
  end
end