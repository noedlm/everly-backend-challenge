class Member < ApplicationRecord
  require 'open-uri'

  has_many :headers

  after_create :store_headers

  def store_headers
    document = Nokogiri::HTML(URI.open(full_url))

    Header::TAGS.each do |tag|
      header_content = document.css(tag).map(&:text).join(' | ')
      Header.new(member_id: id, tag: tag, content: header_content).save if header_content.present?
    end
  end
end
