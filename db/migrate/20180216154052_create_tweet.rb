class CreateTweet < ActiveRecord::Migration[5.1]
  def change
    create_table :tweets do |t|
      t.string :message
      t.integer :user_id
      t.timestamps
    end
  end
end
