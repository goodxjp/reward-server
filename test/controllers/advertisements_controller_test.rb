require 'test_helper'

class AdvertisementsControllerTest < ActionController::TestCase
  setup do
    @advertisement = advertisements(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:advertisements)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create advertisement" do
    assert_difference('Advertisement.count') do
      post :create, advertisement: { campaigns_id: @advertisement.campaigns_id, payment: @advertisement.payment, point: @advertisement.point, price: @advertisement.price }
    end

    assert_redirected_to advertisement_path(assigns(:advertisement))
  end

  test "should show advertisement" do
    get :show, id: @advertisement
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @advertisement
    assert_response :success
  end

  test "should update advertisement" do
    patch :update, id: @advertisement, advertisement: { campaigns_id: @advertisement.campaigns_id, payment: @advertisement.payment, point: @advertisement.point, price: @advertisement.price }
    assert_redirected_to advertisement_path(assigns(:advertisement))
  end

  test "should destroy advertisement" do
    assert_difference('Advertisement.count', -1) do
      delete :destroy, id: @advertisement
    end

    assert_redirected_to advertisements_path
  end
end
