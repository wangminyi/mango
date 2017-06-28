class WholesaleEntry < ApplicationRecord
  extend Enumerize

  serialize :detail_images, JSON

  enumerize :status, in: [
    :visible,
    :invisible,
    :deprecated,
  ], scope: true, default: :visible

  has_many :wholesale_instances
  has_many :visible_wholesale_instances, -> { with_status(:visible) }, class_name: "WholesaleInstance"
  has_many :wholesale_items

  def instance_template
    {
      min_count: self.min_count,
    }
  end

  def cover_image_url
    ActionController::Base.helpers.asset_url(self.cover_image) rescue ""
  end

  def detail_images_url
    self.detail_images.map do |image|
      ActionController::Base.helpers.asset_url(image) rescue ""
    end
  end

  def min_price
    self.wholesale_items.map(&:price).min
  end

  def max_price
    self.wholesale_items.map(&:price).max
  end

  def unit_text
    self.wholesale_items.first.unit_text
  end
end
