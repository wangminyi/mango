class AddReferralCodeAndRefereeIdToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :referral_code, :string
    add_column :users, :referee_id, :integer

    add_index :users, :referral_code
    add_index :users, :referee_id

    User.all.each do |user|
      user.generate_referral_code
    end
  end
end
