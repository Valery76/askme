class AddColorToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :background_color, :string, default: '#005a55'
    add_column :users, :color, :string
  end
end
