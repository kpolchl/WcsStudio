#defmodule WcsStudioWeb.Plugs.Locale do
#  import Plug.Conn
#
#  def init(default), do: default
#
#  def call(conn, _default) do
#    locale = get_locale_from_params(conn) ||
#      get_locale_from_session(conn) ||
#      get_locale_from_header(conn) ||
#      "en"
#
#    Gettext.put_locale(WcsStudioWeb.Gettext, locale)
#    conn |> put_session(:locale, locale)
#  end
#
#  defp get_locale_from_params(conn) do
#    conn.params["locale"]
#  end
#
#  defp get_locale_from_session(conn) do
#    get_session(conn, :locale)
#  end
#
#  defp get_locale_from_header(conn) do
#    case get_req_header(conn, "accept-language") do
#      [header | _] ->
#        header |> String.split(",") |> List.first() |> String.split("-") |> List.first()
#      _ ->
#        nil
#    end
#  end
#end