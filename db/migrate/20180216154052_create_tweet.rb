class CreateTweet < ActiveRecord::Migration[5.1]
  def change
    create_table :tweets do |t|
      t.string :message
      t.string :username
      t.date :timestamp

    end
  end
end
