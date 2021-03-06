class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.integer :import_timestamp_id
      t.string :route_type
      t.string :name
      t.string :http_verb
      t.string :path
      t.string :action_path
      t.string :action
      t.text :original_route_info

      t.timestamps
    end
  end
end
