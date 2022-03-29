defmodule WeatherUiWeb.DashboardLive do
  @moduledoc """
  LiveView for the weather dashboard.
  """

  use WeatherUiWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(WeatherUi.PubSub, "sensors")
    end

    {:ok, assign(socket, wind_speed: 0)}
  end

  @impl Phoenix.LiveView
  def handle_info({:wind_speed, wind_speed, _unit}, socket) do
    {:noreply, assign(socket, wind_speed: wind_speed)}
  end
end
