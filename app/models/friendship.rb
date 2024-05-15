class Friendship < ApplicationRecord
  belongs_to :member
  belongs_to :friend, class_name: 'Member'

  validates :member_id, uniqueness: { scope: :friend_id }

  after_create :create_inverse, unless: :has_inverse?

  private

  def create_inverse
    self.class.create(member_id: friend_id, friend_id: member_id)
  end

  def has_inverse?
    self.class.exists?(member_id: friend_id, friend_id: member_id)
  end
end
