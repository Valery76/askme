class HashtagsController < ApplicationController
  def show
    @hashtag = Hashtag.find(params[:id])
    @questions =
      Question.joins(hashtag_questions: :hashtag).
      where(hashtag_questions: {hashtag: @hashtag})
  end
end
