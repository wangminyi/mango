class AddCampaignCodeToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :campaign_code, :string
  end
end
