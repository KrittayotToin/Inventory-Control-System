require 'test_helper'

class MemberControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get member_index_url
    assert_response :success
  end

  test "should get new" do
    get member_new_url
    assert_response :success
  end

  test "should get create" do
    get member_create_url
    assert_response :success
  end

  test "should get edit" do
    get member_edit_url
    assert_response :success
  end

  test "should get update" do
    get member_update_url
    assert_response :success
  end

  test "should get destroy" do
    get member_destroy_url
    assert_response :success
  end

end
