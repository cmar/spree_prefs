require 'spec_helper'

describe Spree::Preferences::Preferable do

  before :all do
    class A
      include Spree::Preferences::Preferable
      attr_reader :id

      def initialize
        @id = rand(999)
      end

      preference :color, :string, :default => :green
    end

    class B < A
      preference :flavor, :string
    end
  end

  before :each do
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

    it "can be asked if it has a preference definition" do
      @a.prefers?(:color).should be_true
      @a.prefers?(:bad).should be_false

      lambda {
        @a.prefers! :bad
      }.should raise_exception(NoMethodError, "bad preference not defined")
    end
  end

  describe "preference access" do
    it "handles ghost methods for preferences" do
      @a.preferred_color = :blue
      @a.preferred_color.should eq :blue

      @a.prefers_color = :green
      @a.prefers_color?(:green).should be_true
    end

    it "parent and child instances have their own prefs" do
      @a.preferred_color = :red
      @b.preferred_color = :blue

      @a.preferred_color.should eq :red
      @b.preferred_color.should eq :blue
    end

    it "raises when preference not defined" do
      lambda {
        @a.set_preference(:bad, :bone)
      }.should raise_exception(NoMethodError, "bad preference not defined")
    end

    it "builds a hash of preferences" do
      @b.preferred_flavor = :strawberry
      @b.preferences[:flavor].should eq :strawberry
      @b.preferences[:color].should eq :green #default from A
    end

  end

  it "builds cache keys" do
    @a.preference_cache_key(:color).should match /a\/\d+\/color/
    @a.preference_default_cache_key(:color).should eq "a/default/color"
  end
end


