require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  test 'create article' do
    assert_difference 'Article.count' do
      article = Article.create(title: 'The title', content: 'some content')
      assert_equal article.slug, 'the-title'
    end
  end

  test 'create article validations' do
    assert_no_difference 'Article.count' do
      article = Article.create()
      assert article.errors.messages[:title].present?
      assert article.errors.messages[:content].present?
    end
  end

  test 'description' do
    article = article(:with_html)
    assert_equal article.description, 'Title in H1 and some markdown and lot of spaces.'
  end
end
