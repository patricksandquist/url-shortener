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
    ShortenedUrl.create!(
      submitter_id: user.id,
      long_url: long_url,
      short_url: ShortenedUrl.random_code
    )
  end

  def self.random_code
    a = SecureRandom.urlsafe_base64
    while exists?(a)
      a = SecureRandom.urlsafe_base64
    end
    a
  end

  def num_clicks
    Visit.where("shortened_url_id = #{self.id}").count
  end

  def num_uniques
    visitors.count
  end

  def num_recent_uniques
    Visit.select("user_id").where(
      "shortened_url_id = #{self.id}",
      "created_at > #{10.minutes.ago}",
    ).distinct.count
  end

end
