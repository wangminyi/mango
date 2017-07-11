class AddDistributeScopeToWholesaleInstances < ActiveRecord::Migration[5.0]
  def change
    add_column :wholesale_instances, :distribute_scope, :string
  end
end
