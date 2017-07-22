class WholesaleEntry < ApplicationRecord
  extend Enumerize

  serialize :detail_images, JSON

  enumerize :mode, in: [
    :platform, # 平台定期开团
    :user, # 用户开团
  ], scope: true

  has_many :wholesale_instances
  has_many :visible_wholesale_instances, -> { where(visible: true).where("close_at > ?", Time.now) }, class_name: "WholesaleInstance"
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
      id: self.id,
      name: self.name,
      alias: self.alias || self.name,
      mode: self.mode,
      cover_image: self.cover_image_url,
      detail_images: self.detail_images_url,
      summary: self.summary,
      detail: self.detail,
      tips: self.tips,
      min_count: self.min_count,
      min_price: self.min_price,
      max_price: self.max_price,
      original_price: self.mode.user? ? self.wholesale_items.first&.original_price : nil,
      unit_text: "/" + (self.unit_text || ""),
      items: self.wholesale_items.map(&:as_json),
    }
  end
end
