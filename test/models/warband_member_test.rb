require "test_helper"

class WarbandMemberTest < ActiveSupport::TestCase
  test "rating should be 0 when might, will and fate are all 0" do
    member = warband_members(:two)
    assert_equal 0, member.rating
  end

  test "rating should sum might + will + fate multiplied by 5" do
    member = warband_members(:one) # might: 3, will: 2, fate: 1
    assert_equal 30, member.rating
  end

  test "rating should count each point of might as 5" do
    member = warband_members(:one)
    member.might = 1
    member.will = 0
    member.fate = 0
    assert_equal 5, member.rating
  end

  test "rating should count each point of will as 5" do
    member = warband_members(:one)
    member.might = 0
    member.will = 1
    member.fate = 0
    assert_equal 5, member.rating
  end

  test "rating should count each point of fate as 5" do
    member = warband_members(:one)
    member.might = 0
    member.will = 0
    member.fate = 1
    assert_equal 5, member.rating
  end
end
