class Header < ApplicationRecord  
  belongs_to :member

  TAGS = ['h1', 'h2', 'h3'].freeze
end
