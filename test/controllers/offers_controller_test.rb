require 'test_helper'

class OffersControllerTest < ActionController::TestCase
  setup do
    @offer = offers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:offers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create offer" do
    assert_difference('Offer.count') do
      post :create, offer: { campaign: @offer.campaign, campaign_category: @offer.campaign_category, detail: @offer.detail, icon_url: @offer.icon_url, medium: @offer.medium, name: @offer.name, payment: @offer.payment, period: @offer.period, point: @offer.point, price: @offer.price, requirement: @offer.requirement, requirement_detail: @offer.requirement_detail, url: @offer.url }
    end

    assert_redirected_to offer_path(assigns(:offer))
  end

  test "should show offer" do
    get :show, id: @offer
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @offer
    assert_response :success
  end

  test "should update offer" do
    patch :update, id: @offer, offer: { campaign: @offer.campaign, campaign_category: @offer.campaign_category, detail: @offer.detail, icon_url: @offer.icon_url, medium: @offer.medium, name: @offer.name, payment: @offer.payment, period: @offer.period, point: @offer.point, price: @offer.price, requirement: @offer.requirement, requirement_detail: @offer.requirement_detail, url: @offer.url }
    assert_redirected_to offer_path(assigns(:offer))
  end

  test "should destroy offer" do
    assert_difference('Offer.count', -1) do
      delete :destroy, id: @offer
    end

    assert_redirected_to offers_path
  end
end
