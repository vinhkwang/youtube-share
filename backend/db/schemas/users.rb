create_table :users, force: :cascade do |t|
  t.string :email,           null: false, default: ""
  t.string :username,        null: false, default: ""
  t.string :password_digest, null: false, default: ""

  t.timestamps null: false
end

add_index :users, :email,    unique: true, name: "index_users_on_email"
add_index :users, :username, unique: true, name: "index_users_on_username"
