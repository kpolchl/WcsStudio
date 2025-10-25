defmodule WcsStudioWeb.HomeController do
  use WcsStudioWeb, :controller

  def index(conn, _params) do
    lessons_number = rem(WcsStudio.Lesson.count_lessons(), 10)
    posts_number = rem(WcsStudio.Post.count_posts(), 10)
    patterns_number = rem(WcsStudio.Pattern.count_patterns(), 10)
    users_number = rem(WcsStudio.Accounts.count_users(), 10)

    render(conn, :index , lessons_number: lessons_number, posts_number: posts_number, patterns_number: patterns_number, users_number: users_number)
  end
end
