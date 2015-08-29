require 'rails_helper'

RSpec.describe "configs/show", type: :view do
  before(:each) do
    @config = assign(:config, Config.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
