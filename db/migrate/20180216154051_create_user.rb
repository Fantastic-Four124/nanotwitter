class CreateUser < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :username
      t.text :email
      t.string :password
      t.integer :number_of_followers
      t.integer :number_of_leaders
    end
  end
end
