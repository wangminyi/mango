class AddCampaignCodeToOrders < ActiveRecord::Migration[5.0]
  def change
    add_reference :orders, :campaign, index: true
  end
end
