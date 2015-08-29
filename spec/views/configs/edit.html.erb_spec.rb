require 'rails_helper'

RSpec.describe "configs/edit", type: :view do
  before(:each) do
    @config = assign(:config, Config.create!())
  end

  it "renders the edit config form" do
    render

    assert_select "form[action=?][method=?]", config_path(@config), "post" do
    end
  end
end
