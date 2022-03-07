defmodule WeatherUiWeb.PageController do
  use WeatherUiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
