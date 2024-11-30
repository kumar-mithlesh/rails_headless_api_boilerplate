class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string  :username, index: true
      t.string  :email, index: true
      t.string  :password_digest

      t.timestamps
    end
  end
end
