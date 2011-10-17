require 'spec_helper'

describe Cornerstone::Discussion do

  # == ACCESSIBILITY == #
  context "Accessibility:" do
    before do
      @discussion = Factory(:discussion_w_user)
    end
    {:status => "Closed", :reply_count => 5}.each do |attr, value|
      it "should not let me assign the ##{attr}" do
        @discussion.should_not allow_mass_assignment_of(attr => value)
      end
    end
  end

  # == SCOPES == #
  context "Scopes:" do
    describe "#default" do
      it "should not return private discussions" do
        @discussion = Factory(:discussion_w_user, :privte => true)
        Cornerstone::Discussion.all.size.should == 0
      end
    end

    describe "#latest_for_category" do
      before do
        @target_cat = Factory(:category, :name => "Target Category")
      end

      it "should return the youngest discussions for the given category" do
        d = Factory(:discussion_no_user, :category => @target_cat)
        Cornerstone::Discussion.latest_for_category(@target_cat).should == [d]
      end

      it "should not return the latest discussion for a different category" do
        d = Factory(:discussion_w_user, :category => @target_cat,
                                        :created_at => 3.hours.ago)
        Factory(:discussion_w_user)
        Cornerstone::Discussion.latest_for_category(@target_cat).should == [d]
      end

      it "provides the given number of results if available" do
        6.times {Factory(:discussion_w_user, :category => @target_cat)}
        Cornerstone::Discussion.latest_for_category(@target_cat, 5).size.should == 5
      end
    end

  end

  # == VALIDATIONS == #

  context "validations" do

    before do
      @discussion = Factory.build(:discussion)
    end

    [:subject, :category].each do |attr|
      it "requires a #{attr}" do
        @discussion.send("#{attr}=", nil)
        @discussion.should have(1).error_on(attr)
      end
    end

    it "#subject should be 50 characters or less" do
      @discussion.subject = random_alphanumeric(51)
      @discussion.should have(1).error_on(:subject)
    end

    it "should only include the hard coded status types" do
      @discussion.status = "wiggles"
      @discussion.should have(1).error_on(:status)
    end

  end

  # == CALLBACKS == #
  context "Callbacks:" do
    describe "Counter Cache" do
      before do
        @category = Factory(:category, :item_count => 1)
      end

      it "is increased when a discussion is created" do
        @category.item_count.should == 1
        @discussion = Factory(:discussion_no_user, :category => @category)
        @category.reload
        @category.item_count.should == 2
      end

      it "is decreased when a discussion is deleted" do
        @discussion = Factory(:discussion_no_user, :category => @category)
        @category.reload
        @category.item_count.should == 2
        @discussion.destroy
        @category.reload
        @category.item_count.should == 1
      end
    end

    describe "#set_latest_discussion" do
      before do
        @category = Factory(:category)
      end

      pending "only updates on create"

      context "with no current user" do
        it "sets its category's latest discussion author name" do
          @discussion = Factory(:discussion, :category => @category)
          @post = Factory(:post_no_user, :name => "Joe Dinglebat",
                                         :discussion => @discussion)
          @category.reload
          @category.latest_discussion_author.should == "Joe Dinglebat"
        end
      end

      context "with a current user" do
        it "sets its category's latest discussion author name" do
          @user = Factory(:user, :name => "Joe Jingleheimershmeidt")
          @discussion = Factory(:discussion, :category => @category)
          @post = Factory(:post_w_user, :user => @user, :discussion => @discussion)
          @category.reload
          @category.latest_discussion_author.should == "Joe Jingleheimershmeidt"
        end
      end

      it "sets its category's latest discussion date" do
        time = 1.hour.from_now
        Time.stub(:now) {time}
        @discussion = Factory(:discussion_no_user, :category => @category)
        @category.reload
        @category.latest_discussion_date.should.to_s == time.to_s
      end

    end
  end

  # == CLASS METHODS == #

  # == INSTANCE METHODS == #
  context "Instance Methods:" do
    describe "#author_name" do
      it "returns the first post's author name" do
        @user = Factory(:user, :name => "Joe Jingleheimershmeidt")
        @discussion = Factory(:discussion_w_user, :user => @user)
        @discussion.author_name.should == "Joe Jingleheimershmeidt"
      end
    end
    describe "#closed?" do
      it "returns true if the status is the last in the list" do
        @discussion = Factory(:discussion_no_user, :status => Cornerstone::Discussion::STATUS.last)
        @discussion.closed?.should == true
      end
      it "returns false if the status is not the last in the list" do
        @discussion = Factory(:discussion_no_user, :status => Cornerstone::Discussion::STATUS.first)
        @discussion.closed?.should == false      
      end
    end
    describe "#created_by" do
      before do
        @user = Factory(:user)
      end
      it "returns true if the user is a cornerstone admin" do
        @user.stub(:cornerstone_admin?) {true}
        @discussion = Factory(:discussion_w_user, :user => @user)
        @discussion.created_by?(@user).should == true
      end
      it "returns nil if there is no user" do
        @discussion = Factory(:discussion_no_user, :user => nil)
        @user.stub(:cornerstone_admin?) {false}
        @discussion.created_by?(@user).should == nil
      end
      it "returns false if given nil" do
        @discussion = Factory(:discussion_w_user, :user => @user)
        @discussion.created_by?(nil).should == false
      end
      it "returns true if the user created the discussion" do
        @user.stub(:cornerstone_admin?) {false}
        @discussion = Factory(:discussion_w_user, :user => @user)
        @discussion.created_by?(@user).should == true
      end
      it "returns false if the user did not create the discussion" do
        @discussion = Factory(:discussion_w_user, :user => @user)
        @user2 = Factory(:user)
        @user.stub(:cornerstone_admin?) {false}
        @user2.stub(:cornerstone_admin?) {false}
        @discussion.created_by?(@user2).should == false
      end
    end

  end

end

