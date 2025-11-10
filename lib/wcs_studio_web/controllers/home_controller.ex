defmodule WcsStudioWeb.HomeController do
  use WcsStudioWeb, :controller

  def index(conn, _params) do
    lessons_number = round(WcsStudio.Lesson.count_lessons()/ 10)*10
    posts_number = round(WcsStudio.Post.count_posts()/ 10)*10
    patterns_number = round(WcsStudio.Pattern.count_patterns()/ 10)*10
    users_number = round(WcsStudio.Accounts.count_users()/ 10)*10

    render(conn, :index , lessons_number: lessons_number, posts_number: posts_number, patterns_number: patterns_number, users_number: users_number)
  end
end
