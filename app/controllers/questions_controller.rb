class QuestionsController < ApplicationController
  before_action :load_question, only: [:edit, :update, :destroy]

  # Проверяем имеет ли юзер доступ к экшену для всей дествий, кроме задавания
  # вопроса, это действие может вызвать даже неавторизованный пользователь.
  before_action :authorize_user, except: [:create]

  # GET /questions/1/edit
  def edit
  end

  # POST /questions
  def create
    @question = Question.new(question_params)
    @question.author = current_user

    if @question.save
      redirect_to user_path(@question.user), notice: 'Вопрос задан'
    else
      render :edit
    end
  end

  # PATCH/PUT /questions/1
  def update
    if @question.update(question_params.except(:user_id))
      redirect_to user_path(@question.user), notice: 'Вопрос сохранён'
    else
      render :edit
    end
  end

  # DELETE /questions/1
  def destroy
    user = @question.user
    @question.destroy
    redirect_to user_path(user), notice: 'Вопрос удалён'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def load_question
    @question = Question.find(params[:id])
  end

  # Если загруженный из базы вопрос не пренадлежит и текущему залогиненному
  # пользователю — посылаем его с помощью описанного в контроллере
  # ApplicationController метода reject_user.
  def authorize_user
    reject_user unless @question.user == current_user
  end

 # Явно задаем список разрешенных параметров для модели Question. Мы говорим,
  # что у хэша params должен быть ключ :question. Значением этого ключа может
  # быть хэш с ключами: :user_id и :text. Другие ключи будут отброшены.
  def question_params
    # Защита от уязвимости: если текущий пользователь — адресат вопроса,
    # он может менять ответы на вопрос, ему доступно также поле :answer.
    if current_user.present? &&
      params.dig(:question, :user_id)&.to_i == current_user.id
      params.require(:question).permit(:user_id, :text, :answer)
    else
      params.require(:question).permit(:user_id, :text)
    end
  end
end
