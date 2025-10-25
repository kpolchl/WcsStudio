defmodule WcsStudioWeb.LocaleController do
  use WcsStudioWeb, :controller

  def set_locale(conn, %{"locale" => locale, "redirect_to" => redirect_to})
      when locale in ["en", "pl"] do
    conn
    |> put_session(:locale, locale)
    |> redirect(to: redirect_to)
  end

  def set_locale(conn, %{"locale" => locale}) when locale in ["en", "pl"] do
    conn
    |> put_session(:locale, locale)
    |> redirect(to: "/")
  end

  def set_locale(conn, _params), do: redirect(conn, to: "/")
end