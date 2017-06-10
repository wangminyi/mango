class ActiveRecord::Base
  def first_error
    self.errors.messages.values.flatten.first
  end
end