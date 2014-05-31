require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: { address: @user.address, address_public: @user.address_public, admin: @user.admin, description: @user.description, email: @user.email, graduation_year: @user.graduation_year, name: @user.name, out_of_town: @user.out_of_town, paid_amount: @user.paid_amount, password_digest: @user.password_digest, phone_number: @user.phone_number, phone_number_public: @user.phone_number_public, profile_picture_url: @user.profile_picture_url, willing_to_pay_amount: @user.willing_to_pay_amount }
    end

    assert_redirected_to user_path(assigns(:user))
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    patch :update, id: @user, user: { address: @user.address, address_public: @user.address_public, admin: @user.admin, description: @user.description, email: @user.email, graduation_year: @user.graduation_year, name: @user.name, out_of_town: @user.out_of_town, paid_amount: @user.paid_amount, password_digest: @user.password_digest, phone_number: @user.phone_number, phone_number_public: @user.phone_number_public, profile_picture_url: @user.profile_picture_url, willing_to_pay_amount: @user.willing_to_pay_amount }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end
end
