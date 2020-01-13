class SessionsController < ApplicationController
  def new
  end

  # Создает в объекте session новый факт залогиненности пользователя, если он
  # правильно сообщил мэйл/пароль
  def create
    @user = User.authenticate(params[:email], params[:password])

    if @user.present?
      session[:user_id] = @user.id
      redirect_to root_url, notice: 'вы успешно залогинились'
    else
      flash.now.alert = 'Неправильный мэйл или пароль'
      render :new
    end
  end

  # Удаляет сессию залогиненного юзера
  def destroy
    # Затираем в сесси значение ключа :user_id
    session[:user_id] = nil

    # Редиректим пользователя на главную с сообщением
    redirect_to root_url, notice: 'Вы разлогинились! Приходите еще!'
  end
end
