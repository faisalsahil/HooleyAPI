class CreateUserAuthentications < ActiveRecord::Migration[5.0]
  def change
    create_table :user_authentications do |t|
      t.integer :user_id
      t.string :social_site_id
      t.string :social_site
      t.string :profile_image_url

      t.timestamps
    end
  end
end
