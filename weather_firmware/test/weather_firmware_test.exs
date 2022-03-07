defmodule WeatherFirmwareTest do
  use ExUnit.Case
  doctest WeatherFirmware

  test "greets the world" do
    assert WeatherFirmware.hello() == :world
  end
end
