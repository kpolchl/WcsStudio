defmodule WcsStudioWeb.HomeController do
  use WcsStudioWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
