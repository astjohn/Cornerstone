require 'spec_helper'

describe Cornerstone::ActsAsCornerstoneUser do

  class TestUser < ActiveRecord::Base
  end

  class TestUserTwo < ActiveRecord::Base
  end

  context "associations:" do
    before do
      TestUser.send(:acts_as_cornerstone_user)
    end

    it "a Cornerstone Discussion should be related to the given model (User)" do
      TestUser.reflect_on_association(:cornerstone_discussions).should_not be_nil
    end

    context "belongs_to relationships" do

      it "sets up the relationship for a Discussion" do
        Cornerstone::Discussion.reflect_on_association(:test_user).should_not be_nil
      end

      it "can handle multiple relationships" do
        TestUserTwo.send(:acts_as_cornerstone_user)
        Cornerstone::Discussion.reflect_on_association(:test_user).should_not be_nil
        Cornerstone::Discussion.reflect_on_association(:test_user_two).should_not be_nil
      end

    end
  end

  context "options:" do

  end


end

