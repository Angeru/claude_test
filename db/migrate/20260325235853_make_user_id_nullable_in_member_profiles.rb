class MakeUserIdNullableInMemberProfiles < ActiveRecord::Migration[7.1]
  def change
    change_column_null :member_profiles, :user_id, true
  end
end
