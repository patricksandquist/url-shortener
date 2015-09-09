class ShortenedUrl < ActiveRecord::Base
  validates :submitter_id, presence: true
  validates :short_url, presence: true, uniqueness: true

  belongs_to(
    :submitter,
    class_name: "User",
    foreign_key: :submitter_id,
    primary_key: :id
  )

  has_many(
    :visits,
    class_name: "Visit",
    foreign_key: :shortened_url_id,
    primary_key: :id
  )

  has_many(
    :visitors,
    Proc.new { distinct },
    through: :visits,
    source: :visitor
  )

  def self.create_for_user_and_long_url!(user, long_url)
    crypted = ShortenedUrl.random_code
    ShortenedUrl.create!(
      submitter_id: user.id,
      long_url: long_url,
      short_url: crypted
    )
    crypted
  end

  def self.random_code
    a = SecureRandom.urlsafe_base64
    while exists?(a)
      a = SecureRandom.urlsafe_base64
    end
    a
  end

  def num_clicks
    visits.count
  end

  def num_uniques
    visitors.count
  end

  def num_recent_uniques
    visits.select(:user_id).distinct.where(created_at: (10.minutes.ago)..Time.now).count
  end

end
