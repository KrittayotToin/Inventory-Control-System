require 'test_helper'

class EquipmentControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get equipment_index_url
    assert_response :success
  end

end
