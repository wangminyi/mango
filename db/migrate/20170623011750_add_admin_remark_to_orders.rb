class AddAdminRemarkToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :admin_remark, :text
  end
end
