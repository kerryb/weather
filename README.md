# Nerves Weather Station

An attempt to build a weather station using a [Raspberry Pi Zero
W](https://www.raspberrypi.com/products/raspberry-pi-zero-w/),
[Nerves](https://www.nerves-project.org/),
[Phoenix](https://www.phoenixframework.org/) and [some sensors from
AliExpress](https://www.aliexpress.com/item/1214985366.html)
([datasheet](https://www.sparkfun.com/datasheets/Sensors/Weather/Weather%20Sensor%20Assembly..pdf)).

## Building and deploying

Everything should be doable using the top-level Makefile (run `make help` to
list the targets). The main ones are `all` (the default), `test`, `firmware`
and either `burn` (to prepare a new SD card) or `upload` (to update the running
firmware over ssh).

The hostname is set to `weather.local`, which can be used for ssh or http
access.

You need to ssh to the Pi once manually before running `make upload`, to allow
you to accept the host key.

## Progress so far

### Wind speed

  - [x] Write a server to interface with the anemometer
  - [x] Test with hardware

### Wind direction

  - [x] Write a server to interface with the wind vane
  - [ ] Test with hardware

### Rainfall

  - [x] Write a server to interface with the rain sensor
  - [ ] Test with hardware

### Temperature/pressure/humidity

  - [x] Read from BME280 sensor
  - [x] Cache value and update regularly

### UI

  - [ ] Display current values
  - [ ] Real time updates
  - [ ] History
