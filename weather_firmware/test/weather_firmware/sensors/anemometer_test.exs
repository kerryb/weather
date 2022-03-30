defmodule WeatherFirmware.Sensors.AnemometerTest do
  use ExUnit.Case, async: true
  alias WeatherFirmware.Sensors.Anemometer

  @pin Application.compile_env!(:weather_firmware, :pins).anemometer

  setup %{test: test} do
    # Start a server named to match the test, to guarantee uniqueness
    {:ok, anemometer} = Anemometer.start_link(test)
    {:ok, anemometer: anemometer}
  end

  describe "WeatherFirmware.Sensors.Anemometer" do
    test "initially returns a wind speed of zero", %{anemometer: anemometer} do
      assert Anemometer.speed(anemometer) == 0
    end

    test "calculates the wind speed based on the latest ten pulses (3Hz = 2m/s)", %{
      anemometer: anemometer
    } do
      # we only care about the first and eleventh (10 gaps)
      send(anemometer, {:circuits_gpio, @pin, 10_000_000_000, 0})

      for n <- 1..9 do
        send(anemometer, {:circuits_gpio, @pin, 10_000_000_000 + n * 10_000_000, 0})
      end

      send(anemometer, {:circuits_gpio, @pin, 10_333_333_333, 0})

      assert_in_delta Anemometer.speed(anemometer), 20, 0.001
    end

    # TODO: only check for messages from 'our' anemometer; check speed value
    test "broadcasts a pubsub message ten times a second" do
      :ok = Phoenix.PubSub.subscribe(WeatherUi.PubSub, "sensors")
      assert_receive {:wind_speed, 0, :metres_per_second}, 150
    end

    # TODO: handle wind speed reducing to zero
  end
end
