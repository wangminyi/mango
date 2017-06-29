class WholesaleItem < ApplicationRecord
  belongs_to :wholesale_entry

  def as_json
    {
      name: self.alias || self.name,
      image: ActionController::Base.helpers.asset_url(self.image),
      price: self.price,
      unit_text: "/" + (self.unit_text || ""),
      description: self.description,
      sales_volume: self.sales_volume || 0,
      count: 0,
    }
  end
end