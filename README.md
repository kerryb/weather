# Nerves Weather Station

An attempt to build a weather station using a [Raspberry Pi Zero
W](https://www.raspberrypi.com/products/raspberry-pi-zero-w/),
[Nerves](https://www.nerves-project.org/),
[Phoenix](https://www.phoenixframework.org/) and [some sensors from
AliExpress](https://www.aliexpress.com/item/1214985366.html)
([datasheet](https://www.sparkfun.com/datasheets/Sensors/Weather/Weather%20Sensor%20Assembly..pdf)).

## Progress so far

### Wind speed

- [x] Write a server to interface with the anemometer
- [] Test with hardware

### Wind direction

- [] Write a server to interface with the wind vane
- [] Test with hardware

### Rainfall

- [] Write a server to interface with the rain sensor
- [] Test with hardware

### Temperature/pressure/humidity

- [x] Read from BME280 sensor
- [x] Updates once a minute

### UI

- [] Display current values
- [] Real time updates
- [] History
