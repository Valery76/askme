class CreateHashtagQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :hashtag_questions do |t|
      t.references :hashtag, foreign_key: true
      t.references :question, foreign_key: true

      t.timestamps
    end
  end
end
