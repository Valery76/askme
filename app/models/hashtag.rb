class Hashtag < ApplicationRecord
  has_many :hashtag_questions, dependent: :destroy
  has_many :questions, through: :hashtag_questions

  REGEX = /#[[:word:]]+/
end
