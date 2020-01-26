class AddColorToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :background_color, :string
    add_column :users, :color, :string
  end
end
