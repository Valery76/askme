# (c) goodprogrammer.ru

# Эта библиотека понадобится нам для шифрования.
require 'openssl'

# Модель пользователя.
#
# Каждый экземпляр этого класса — загруженная из БД инфа о конкретном юзере.

class User < ApplicationRecord
  # Параметры работы для модуля шифрования паролей
  ITERATIONS = 20_000
  DIGEST = OpenSSL::Digest::SHA256.new

  # Виртуальное поле, которое не сохраняется в базу. Из него перед сохранением
  # читается пароль, и сохраняется в базу уже зашифрованная версия пароля в
  # реальные поля password_salt и password_hash.
  attr_accessor :password

  # Эта команда добавляет связь с моделью Question на уровне объектов она же
  # добавляет метод .questions к данному объекту.
  #
  # Вспоминайте уроки про реляционные БД и связи между таблицами.
  #
  # Когда мы вызываем метод questions у экземпляра класса User, рельсы
  # поймут это как просьбу найти в базе все объекты класса Questions со
  # значением user_id равный user.id.
  has_many :questions

  # Валидация, которая проверяет, что поля email и username не пустые и не равны
  # nil. Если не задан email и username, объект не будет сохранен в базу.
  validates :email, :username, presence: true

  # Валидация, которая проверяет уникальность полей email и username. Если в
  # базе данных уже есть записи с такими email и/или username, объект не будет
  # сохранен в базу.
  validates :email, :username, uniqueness: true

  # Задача 48-1. Задание1.
  # Проверка формата электронной почты пользователя
  validates :email, format: { with: /\A.+@.+\z/ }

  # Задача 48-2.
  # Чтобы юзернеймы пользователей попадали в базу только в нижнем регистре.
  before_validation :username_to_downcase

  # Задача 48-1. Задание2.
  # Проверка максимальной длины юзернейма пользователя (не больше 40 символов)
  validates :username, length: { maximum: 40 }

  # Задача 48-1. Задание3.
  # Проверка формата юзернейма пользователя (только латинские буквы, цифры, и знак _)
  validates :username, format: { with: /\A[0-9a-zA-Z_]+\z/ }

  # validates :background_color, format: { with: /\A#\h{6}\z/ }, on: :update
  validates :background_color, format: { with: /\A#\h{6}\z/ }, allow_blank: true

  # Поле password нужно только при создании (create) нового юзера — регистрации.
  # При аутентификации (логине) мы будем сравнивать уже зашифрованные поля.
  validates :password, presence: true, on: :create

  # Валидация, которая проверяет совпадения значений полей password и
  # password_confirmation. Понадобится при создании формы регистрации, чтобы
  # снизить число ошибочно введенных паролей.
  validates_confirmation_of :password

  after_validation :set_color

  # Перед сохранением объекта в базу, создаем зашифрованный пароль, который
  # будет хранится в БД.
  before_save :encrypt_password

  # Шифруем пароль, если он задан
  def encrypt_password
    if password.present?
      # Создаем т. н. «соль» — рандомная строка усложняющая задачу хакерам по
      # взлому пароля, даже если у них окажется наша база данных.
      self.password_salt = User.hash_to_string(OpenSSL::Random.random_bytes(16))

      # Создаем хэш пароля — длинная уникальная строка, из которой невозможно
      # восстановить исходный пароль. Однако, если правильный пароль у нас есть,
      # мы легко можем получить такую же строку и сравнить её с той, что в базе.
      self.password_hash = User.hash_to_string(
        OpenSSL::PKCS5.pbkdf2_hmac(
          password, password_salt, ITERATIONS, DIGEST.length, DIGEST
        )
      )

      # Оба поля окажутся записанными в базу при сохранении (save).
    end
  end

  # Служебный метод, преобразующий бинарную строку в 16-ричный формат,
  # для удобства хранения.
  def self.hash_to_string(password_hash)
    password_hash.unpack('H*')[0]
  end

  # Основной метод для аутентификации юзера (логина). Проверяет email и пароль,
  # если пользователь с такой комбинацией есть в базе возвращает этого
  # пользователя. Если нету — возвращает nil.
  def self.authenticate(email, password)
    # Сперва находим кандидата по email
    user = find_by(email: email)

    # Если пользователь не найдет, возвращаем nil
    return nil unless user.present?

    # Формируем хэш пароля из того, что передали в метод
    hashed_password = User.hash_to_string(
      OpenSSL::PKCS5.pbkdf2_hmac(
        password, user.password_salt, ITERATIONS, DIGEST.length, DIGEST
      )
    )

    # Обратите внимание: сравнивается password_hash, а оригинальный пароль так
    # никогда и не сохраняется нигде. Если пароли совпали, возвращаем
    # пользователя.
    return user if user.password_hash == hashed_password

    # Иначе, возвращаем nil
    nil
  end

  private

  def username_to_downcase
    self.username = username.downcase
  end

  def set_color
    bc = background_color

    if bc.present?
      self.color =
        bc.gsub(/\h{2}/) { |hex| (255 - hex.to_i(16)).to_s(16).rjust(2, '0') }
    end
  end
end
