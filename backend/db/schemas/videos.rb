create_table :videos, force: :cascade do |t|
  t.bigint   :user_id,       null: false
  t.string   :youtube_id,    null: false, default: ""
  t.string   :youtube_url,   null: false, default: ""
  t.string   :title,         null: false, default: ""
  t.string   :thumbnail_url
  t.text     :description
  t.datetime :shared_at,     null: false, default: -> { "NOW()" }

  t.timestamps null: false
end

add_index       :videos, :user_id,    name: "index_videos_on_user_id"
add_index       :videos, :youtube_id, name: "index_videos_on_youtube_id"
add_foreign_key :videos, :users,      name: "fk_videos_user_id"
