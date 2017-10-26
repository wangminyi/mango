class AddMaxCountToWholesaleInstances < ActiveRecord::Migration[5.0]
  def change
    add_column :wholesale_instances, :max_count, :integer, after: :min_count
  end
end
