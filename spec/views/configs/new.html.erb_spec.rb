require 'rails_helper'

RSpec.describe "configs/new", type: :view do
  before(:each) do
    assign(:config, Config.new())
  end

  it "renders new config form" do
    render

    assert_select "form[action=?][method=?]", configs_path, "post" do
    end
  end
end
