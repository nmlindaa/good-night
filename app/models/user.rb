class User < ApplicationRecord
  validates :name, presence: true

  has_many :active_followings,
           -> { where(unfollowed_at: nil) },
           class_name: "Follow",
           foreign_key: "follower_id",
           dependent: :destroy
  has_many :following_users,
           through: :active_followings,
           source: :followed

  has_many :active_followers,
           -> { where(unfollowed_at: nil) },
           class_name: "Follow",
           foreign_key: "followed_id",
           dependent: :destroy
  has_many :follower_users,
           through: :active_followers,
           source: :follower

  has_many :all_followings,
           class_name: "Follow",
           foreign_key: "follower_id",
           dependent: :destroy
  has_many :all_followers,
           class_name: "Follow",
           foreign_key: "followed_id",
           dependent: :destroy

  has_many :sleep_records, dependent: :destroy
end
