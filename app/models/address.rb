class Address < ApplicationRecord
  extend Enumerize

  enumerize :gender, in: [
    :female,
    :male,
  ], scope: true

  belongs_to :user

  after_save :set_default, if: "self.is_default"

  validates_presence_of :name, :gender, :phone, :garden, :house_number, message: "地址信息不完整"
  validates_inclusion_of :is_default, in: [true, false], message: "地址信息不完整"
  validates_format_of :phone, with: /\A[0-9]{11}\z/, message: "手机格式不正确"

  def to_json
    {
      id: self.id,
      name: self.name,
      gender: self.gender,
      phone: self.phone,
      garden: self.garden,
      house_number: self.house_number,
      is_default: self.is_default,
    }
  end

  private
    def set_default
      self.user.addresses.where.not(id: self.id).update_all(is_default: false)
    end
end
