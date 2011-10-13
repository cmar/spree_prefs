require 'spec_helper'

describe Spree::Preferences::Base do

  before :each do
    @base = Spree::Preferences::BaseInstance.new
  end

  describe "Preferences" do
    it "builds a key from class name and id" do
      object = Object.new
      object.should_receive(:id).and_return(22)
      @base.preference_key(object).should eq "Object::22"

      object = Object.new
      @base.preference_key(object).should eq "Object"
    end
  end

  describe "Definitions" do
    before :each do
      @object = double
      @definition = Spree::Preferences::Definition.new do |d|
        d.name = :color
        d.type = :string
        d.default = "blue"
      end
      @base.add_definition(@definition, @object)
    end

    it "adds a definition for an object" do
      @base.definitions(@object).should include @definition
    end

    it "finds a definition for an object" do
      @base.find_definition(:color, @object).should eq @definition
    end

    it "prefers? is true if definition available" do
      @base.prefers?(:color, @object).should be_true
      @base.prefers?(:bad, @object).should be_false
    end

    it "includes the defintion in the defaults for object" do
      @base.defaults(@object).should have_key :color
    end
  end
end


