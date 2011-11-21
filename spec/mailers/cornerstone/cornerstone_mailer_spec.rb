require "spec_helper"

describe Cornerstone::CornerstoneMailer do
  describe "new_discussion" do
    let(:discussion) { Factory(:discussion_w_user) }
    let(:mail) { Cornerstone::CornerstoneMailer.new_discussion(discussion.posts.first, discussion) }

    it "renders the headers" do
      mail.subject.should eq(I18n.t('cornerstone.cornerstone_mailer.new_discussion.subject'))
      mail.to.should eq(Cornerstone::Config.admin_emails)
      mail.from.should eq([Cornerstone::Config.mailer_from])
    end

    it "renders the body" do
      mail.body.encoded.should match("new discussion")
    end
  end

  describe "new_discussion_user" do
    let(:discussion) { Factory(:discussion_w_user) }
    let(:mail) { Cornerstone::CornerstoneMailer.new_discussion_user(discussion.posts.first, discussion) }

    it "renders the headers" do
      mail.subject.should eq(I18n.t('cornerstone.cornerstone_mailer.new_discussion_user.subject'))
      mail.to.should eq([discussion.posts.first.author_email])
      mail.from.should eq([Cornerstone::Config.mailer_from])
    end

    it "renders the body" do
      mail.body.encoded.should match("Your discussion")
    end
  end

  describe "new_post" do
    let(:discussion) { Factory(:discussion_w_user) }
    let(:post) { discussion.posts.first }
    let(:mail) { Cornerstone::CornerstoneMailer.new_post(post.author_name,
                                                         post.author_email, post, discussion) }

    it "renders the headers" do
      mailto = [post.author_email]

      subject = "Cornerstone: New reply for - #{discussion.subject}"
      mail.subject.should eq(subject)
      mail.to.should eq(mailto)
      mail.from.should eq([Cornerstone::Config.mailer_from])
    end

    it "renders the body" do
      mail.body.encoded.should match("new reply")
    end

  end

end
