require 'test_helper'

class LogControlControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get log_control_index_url
    assert_response :success
  end

  test "should get new" do
    get log_control_new_url
    assert_response :success
  end

  test "should get create" do
    get log_control_create_url
    assert_response :success
  end

  test "should get edit" do
    get log_control_edit_url
    assert_response :success
  end

  test "should get update" do
    get log_control_update_url
    assert_response :success
  end

  test "should get destroy" do
    get log_control_destroy_url
    assert_response :success
  end

end
