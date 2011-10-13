require 'spec_helper'

describe Spree::Preferences::Preferable do

  before :each do
    class A
      include Spree::Preferences::Preferable
      preference :color, :string, :default => :green
    end

    class B < A
      preference :flavor, :string
    end

    @a = A.new
    @b = B.new
  end

  describe "preference definitions" do
    it "parent should not see child definitions" do
      A.prefers?(:color).should be_true
      A.prefers?(:flavor).should_not be_true
    end

    it "child should have parent and own definitions" do
      B.prefers?(:color).should be_true
      B.prefers?(:flavor).should be_true
    end

    it "instances have defaults" do
      @a.preferred_color.should eq :green
      @b.preferred_color.should eq :green
      @b.preferred_flavor.should be_nil
    end
  end

  # it "handles ghost methods for preferences" do
  #   @a.preferred_color = "blue"
  #   @a.preferred_color.should eq "blue"

  #   @a.prefers_color = "blue"
  #   @a.prefers_color?("blue").should be_true
  # end

  # it "parent and child instances have their own prefs" do
  #   @a.preferred_color = :red
  #   @b.preferred_color = :blue

  #   @a.preferred_color.should eq :red
  #   @b.preferred_color.should eq :blue
  # end

  # it "raises when preference not defined" do
  #   lambda {
  #     @a.set_preference(:bad, :bone)
  #   }.should raise_exception(NoMethodError, "bad preference not defined")
  # end

  # it "builds a hash of preferences" do
  #   @b.preferred_flavor = :strawberry
  #   puts @b.preferences
  #   @b.preferences[:flavor].should eq :strawberry
  #   @b.preferences[:color].should eq :green #default from A
  # end
end


