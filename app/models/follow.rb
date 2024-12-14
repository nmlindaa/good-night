class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :followed_id, presence: true
  validates :follower_id, presence: true
  validate :validate_follow, on: :create

  scope :active, -> { where(unfollowed_at: nil) }
  scope :unfollowed, -> { where.not(unfollowed_at: nil) }

  def self.follow(follower_id, followed_id)
    transaction do
      begin
        follower = User.lock.find(follower_id)
        followed = User.lock.find(followed_id)
        follow_record = find_or_initialize_by(follower_id: follower_id, followed_id: followed_id)

        follow_record.with_lock do
          if follow_record.persisted? && follow_record.unfollowed_at.present?
            follow_record.refollow!
          else
            follow_record.save!
          end
        end

        follow_record
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error "Failed to follow: #{e.message}"
        raise
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Invalid follow attempt: #{e.message}"
        raise
      end
    end
  end

  def self.unfollow(follower_id, followed_id)
    transaction do
      follower = User.lock.find(follower_id)
      followed = User.lock.find(followed_id)

      follow = find_by(follower_id: follower_id, followed_id: followed_id)

      if follow
        follow.with_lock do
          follow.unfollow!
        end
      else
        Rails.logger.error "Not following"
      end

      follow
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error "Failed to unfollow: #{e.message}"
      raise
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Invalid unfollow attempt: #{e.message}"
      raise
    end
  end


  def unfollow!
    update!(unfollowed_at: Time.current)
  end

  def refollow!
    update!(unfollowed_at: nil)
  end

  private

  def validate_follow
    if follower_id == followed_id
      errors.add(:base, "can't follow themselves")
    elsif Follow.active.exists?(follower_id: follower_id, followed_id: followed_id)
      errors.add(:base, "already following this user")
    end
  end
end
