class WholesaleEntry < ApplicationRecord
  extend Enumerize

  serialize :detail_images, JSON

  enumerize :status, in: [
    :visible,
    :invisible,
    :deprecated,
  ], scope: true, default: :visible

  has_many :wholesale_instances
  has_many :visible_wholesale_instances, -> { with_status(:visible).where("close_at > ?", Time.now) }, class_name: "WholesaleInstance"
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

  def as_json
    {
      name: self.name,
      cover_image: self.cover_image_url,
      detail_images: self.detail_images_url,
      summary: self.summary,
      detail: self.detail,
      tips: self.tips.gsub("\n", "<br/>"),
      min_count: self.min_count,
      min_price: self.min_price,
      max_price: self.max_price,
      unit_text: "/" + (self.unit_text || ""),
      instances: self.wholesale_instances.map(&:as_json),
      items: self.wholesale_items.map(&:as_json),
    }
  end
end
