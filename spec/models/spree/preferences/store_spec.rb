require 'spec_helper'

describe Spree::Preferences::Store do
  before :each do
    @store = Spree::Preferences::StoreInstance.new
  end

  it "sets and gets a key" do
    @store.set :test, :value
    @store.exist?(:test).should be_true
    @store.get(:test).should eq :value
  end

  it "can set and get false values beacuse cache return nil" do
    @store.set :test, false
    @store.get(:test).should be_instance_of FalseClass
  end
end



