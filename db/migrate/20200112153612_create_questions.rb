class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
      t.string :text
      t.string :answer

      t.timestamps
    end

    # Добавляет в таблицу questions поле user_id, ссылающееся на таблицу users
    add_reference :questions, :user, index: true, foreign_key: true
  end
end
