class Address < ApplicationRecord
  belongs_to :user

  after_save :set_default, if: "self.is_default"

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
