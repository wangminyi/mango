class WholesaleInstance < ApplicationRecord
  extend Enumerize

  enumerize :mode, in: [
    :platform,
    :user,
  ], scope: true

  enumerize :status, in: [
    :ungrouped, # 不满足人数
    :grouped,   # 满足人数
    :distributed, # 已处理完毕
  ], scope: true, default: :ungrouped

  enumerize :distribute_scope, in: [
    :morning,
    :afternoon,
    :all_day,
  ], scope: true, default: :all_day

  belongs_to :wholesale_entry
  belongs_to :user
  has_many :wholesale_orders

  def as_json
    {
      id: self.id,
      name: self.name,
      short_name: self.name.split(/[(（]/)[0],
      mode: self.mode,
      min_count: self.min_count,
      max_count: self.max_count,
      current_count: self.current_count,
      distribute_scope: self.distribute_scope,
      distribute_date_from: distribute_date_from,
      distribute_date_to: distribute_date_to,
      can_select: self.max_count.nil? || self.max_count > self.current_count,
    }
  end

  def participants
  end

  def self.selectable_options
    self.where("wholesale_instances.close_at > ?", 1.weeks.ago).preload(:wholesale_entry).order(:close_at).map do |instance|
      [[instance.wholesale_entry.select_option_text, instance.name].join("-"), instance.id]
    end
  end
end
