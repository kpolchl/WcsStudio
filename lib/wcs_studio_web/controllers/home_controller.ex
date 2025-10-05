defmodule WcsStudioWeb.HomeController do
  use WcsStudioWeb, :controller

  def index(conn, _params) do
    slides = [
      %{image_url: "/images/slide1.jpg", title: "Dance stupid", subtitle: "Is's not so hard"},
      %{image_url: "/images/slide2.jpg", title: "Come on break a leg", subtitle: "Mean not literally"},
      %{image_url: "/images/slide3.jpg", title: "Even he can dance", subtitle: "Sign up today"}
    ]
    render(conn, :index, slides: slides)
  end
end
