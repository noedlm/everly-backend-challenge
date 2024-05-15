class MembersController < ApplicationController
  def index
    @members = Member.select('members.*, COUNT(friendships.id) AS friends_count')
                     .left_outer_joins(:friendships)
                     .group('members.id')

    respond_to do |format|
      format.html
      format.json { render json: @members }
    end
  end

  def show
    @member = Member.find_by(id: params[:id])
    @headers = @member.headers
    @friends = @member.friends

    flash[:error] = @member.blank? ? 'Member not found' : nil

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

  def search
    # TODO: Add better error handling and user feedback
    # clear the flash so the correct response is displayed
    flash[:error] = nil

    @member = Member.find_by(id: params[:id])
    flash[:error] = 'Member not found' and (return render :search) if @member.blank?
    
    flash[:error] = 'Query not found' and (return render :search) if params[:query].blank?
    @query = params[:query]

    friend_ids = @member.friendships.pluck(:friend_id)
    @expert = Member.joins(:headers).where('headers.content LIKE ?', "%#{@query}%").where.not(id: friend_ids + [@member.id]).first
    flash[:error] = 'No expert found' and (return render :search) if @expert.blank?

    @friend_path = find_friend_path(@member, @expert)
    flash[:error] = 'No friend path found' if @friend_path.blank?
  end

  private

  # TODO: Move this into a concern if it ends up being reused in other methods
  def find_friend_path(member, expert)
    visited = {}
    queue = [[member, [member]]]

    # BFS to find a connection between a member doing the search and an expert
    while queue.present?
      current_member, friend_path = queue.shift
      return friend_path if current_member == expert

      current_member.friends.each do |friend|
        unless visited[friend.id]
          visited[friend.id] = true
          queue << [friend, friend_path + [friend]]
        end
      end
    end

    # Return an empty path if no connection exists between member and expert
    []
  end

  def member_params
    params.fetch(:member, {}).permit(:first_name, :last_name, :url)
  end
end
