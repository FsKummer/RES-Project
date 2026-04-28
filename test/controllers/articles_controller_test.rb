require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url
    assert_response :success
  end

  test "should get show" do
    user = User.create!(
      email: "publisher@example.com",
      password: "password",
      first_name: "Test",
      last_name: "Publisher",
      nickname: "publisher"
    )
    category = Category.create!(name: "Science")
    article = Article.create!(
      title: "Accepted article",
      subtitle: "A published article",
      rich_body: "Body",
      accepted: true,
      user: user,
      category: category
    )

    get article_url(article)
    assert_response :success
  end
end
