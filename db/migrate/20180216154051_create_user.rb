class CreateUser < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :last_name
      t.string :first_name
      t.string :username
      t.text :email
      t.string :password
      t.string :digest
      t.integer :Number_of_followers
      t,integer :Number_of_leaders
    end
  end
end
