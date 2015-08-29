require 'rails_helper'

RSpec.describe "configs/index", type: :view do
  before(:each) do
    assign(:configs, [
      Config.create!(),
      Config.create!()
    ])
  end

  it "renders a list of configs" do
    render
  end
end
