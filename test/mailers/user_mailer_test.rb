require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "welcome" do
    user = User.new(email: "user@example.com")

    mail = UserMailer.with(user: user).welcome

    assert_equal "Welcome to Round Earth Society!", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["admin@roundearthsociety.org"], mail.from
    assert_match user.email, mail.body.encoded
  end
end
