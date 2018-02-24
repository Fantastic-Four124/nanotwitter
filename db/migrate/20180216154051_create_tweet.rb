class CreateTweet < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :message
      t.date :timestamp

    end
  end
end
