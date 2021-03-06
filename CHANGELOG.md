# Changelog

## v0.2.4

This release adds support for reading the BME680's gas resistance sensor. In the
future, this will be converted to an indoor air quality measurement.

* API changes
  * Sensor measurements are now obtained by calling `BMP280.measure/1` for
    consistency with other Elixir sensor libraries. `BMP280.read/1` is
    deprecated.

* Improvements
  * The library now polls the sensor once a second. Calls to `BMP280.measure/1`
    return the latest reading rather than making an I2C transaction.
  * Measurements now include a timestamp (`System.monotonic_time(:millisecond)`)
  * Various internal code improvements to make it easier to support many Bosch
    sensors

## v0.2.3

* New features
  * Support temperature, humidity and pressure measurements on the BME680. VOC
    measurements are not supported yet.

## v0.2.2

Note: This release removes the non-SI conversion helper functions. They were
inconsistently defined, and it seems better for some other library to care more
about conversions.

* New features
  * Add dew point approximation

## v0.2.1

* Bug fixes
  * Fix `BMP280.detect/2` so that it only probes one I2C bus address.

## v0.2.0

* New features
  * Add support for the BME280 and for reading relative humidity measurements
    from it

## v0.1.1

* Fixes
  * Fixed `:bus_address` parameter. It was incorrectly referred to as `:address`
    when used.

## v0.1.0

Initial release
