class Member < ApplicationRecord
  require 'open-uri'

  has_many :headers
  has_many :friendships
  has_many :friends, through: :friendships, source: :friend

  validates :first_name, :last_name, :url, presence: true

  after_create :store_headers

  def store_headers
    begin
      document = Nokogiri::HTML(URI.open(url))
    rescue Net::OpenTimeout
      Rails.logger.error("Timeout error when trying to open #{url}")
      return
    rescue StandardError => e
      Rails.logger.error("Error when trying to open #{url}: #{e.message}")
      return
    end

    Header::TAGS.each do |tag|
      header_content = document.css(tag).map(&:text).join(' | ')
      Header.new(member_id: id, tag: tag, content: header_content).save if header_content.present?
    end
  end
end
