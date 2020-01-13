module UsersHelper
  def user_statistics(user)
    number_of_questions = user.questions.count
    number_of_answered_questions = user.questions.select { |q| q.answer.present? }.count

    {
      number_of_questions: number_of_questions,
      number_of_answered_questions: number_of_answered_questions,
      number_of_questions_to_answer: number_of_questions - number_of_answered_questions
    }
  end
end
