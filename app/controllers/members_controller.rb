class MembersController < ApplicationController
  include Respondable

  def index
    @members = Member.select('members.*, COUNT(friendships.id) AS friends_count')
                     .left_outer_joins(:friendships)
                     .group('members.id')

    
    respond_html_or_json(object: @members)
  end

  def show
    @member = Member.find_by(id: params[:id])
    @headers = @member&.headers
    @friends = @member&.friends

    flash[:error] = @member.blank? ? 'Member not found' : nil

    respond_html_or_json(error: flash[:error], object: @member)
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
      respond_html_or_json(redirect: true, action: @member, object: @member)
    else
      respond_html_or_json(action: 'new', object: @member.errors, status: :bad_request)
    end
  end

  def search
    # clear the flash so the correct response is displayed
    flash[:error] = nil

    @member = Member.find_by(id: params[:id])
    respond_html_or_json(error: 'Member not found') and return if @member.blank?
    
    respond_html_or_json(error: 'Query not found') and return if params[:query].blank?
    @query = params[:query]

    friend_ids = @member.friendships.pluck(:friend_id)
    @expert = Member.joins(:headers).where('headers.content LIKE ?', "%#{@query}%").where.not(id: friend_ids + [@member.id]).first
    respond_html_or_json(error: 'No expert found') and return if @expert.blank?

    @friend_path = find_friend_path(@member, @expert)
    flash[:error] = 'No friend path found' if @friend_path.blank?

    respond_html_or_json(error: flash[:error], object: @friend_path)
  end

  private

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
