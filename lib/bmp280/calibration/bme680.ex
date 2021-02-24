defmodule BMP280.Calibration.BME680 do
  @moduledoc false

  @type t() :: %{
          type: :bme680,
          par_t1: integer,
          par_t2: integer,
          par_t3: integer,
          par_p1: integer,
          par_p2: integer,
          par_p3: integer,
          par_p4: integer,
          par_p5: integer,
          par_p6: integer,
          par_p7: integer,
          par_p8: integer,
          par_p9: integer,
          par_p10: integer,
          par_h1: integer,
          par_h2: integer,
          par_h3: integer,
          par_h4: integer,
          par_h5: integer,
          par_h6: integer,
          par_h7: integer,
          par_gh1: integer,
          par_gh2: integer,
          par_gh3: integer,
          range_switching_error: integer,
          res_heat_range: integer,
          res_heat_val: integer
        }

  @spec from_binary({integer(), integer(), integer(), <<_::184>>, <<_::112>>}) :: t()
  def from_binary(
        {res_heat_val, res_heat_range, range_switching_error,
         <<par_t2::little-signed-16, par_t3::signed, _skip8D, par_p1::little-16,
           par_p2::little-signed-16, par_p3::signed, _skip93, par_p4::little-signed-16,
           par_p5::little-signed-16, par_p7::signed, par_p6::signed, _skip9A, _skip9B,
           par_p8::little-signed-16, par_p9::little-signed-16, par_p10>>,
         <<par_h2h, par_h2l::4, par_h1l::4, par_h1h, par_h3::signed, par_h4::signed,
           par_h5::signed, par_h6, par_h7::signed, par_t1::little-16, par_gh2::little-signed-16,
           par_gh1::signed, par_gh3::signed>>}
      ) do
    %{
      type: :bme680,
      par_t1: par_t1,
      par_t2: par_t2,
      par_t3: par_t3,
      par_p1: par_p1,
      par_p2: par_p2,
      par_p3: par_p3,
      par_p4: par_p4,
      par_p5: par_p5,
      par_p6: par_p6,
      par_p7: par_p7,
      par_p8: par_p8,
      par_p9: par_p9,
      par_p10: par_p10,
      par_h1: par_h1h * 16 + par_h1l,
      par_h2: par_h2h * 16 + par_h2l,
      par_h3: par_h3,
      par_h4: par_h4,
      par_h5: par_h5,
      par_h6: par_h6,
      par_h7: par_h7,
      par_gh1: par_gh1,
      par_gh2: par_gh2,
      par_gh3: par_gh3,
      range_switching_error: range_switching_error,
      res_heat_range: res_heat_range,
      res_heat_val: res_heat_val
    }
  end

  @spec raw_to_temperature(t(), integer()) :: float()
  def raw_to_temperature(cal, raw_temp) do
    var1 = (raw_temp / 16384 - cal.par_t1 / 1024) * cal.par_t2

    var2 =
      (raw_temp / 131_072 - cal.par_t1 / 8192) * (raw_temp / 131_072 - cal.par_t1 / 8192) *
        cal.par_t3 * 16

    (var1 + var2) / 5120
  end

  @spec raw_to_pressure(t(), number(), integer()) :: float()
  def raw_to_pressure(cal, temp, raw_pressure) do
    t_fine = temp * 5120

    var1 = t_fine / 2 - 64000
    var2 = var1 * var1 * cal.par_p6 / 131_072
    var2 = var2 + var1 * cal.par_p5 * 2
    var2 = var2 / 4 + cal.par_p4 * 65536
    var1 = (cal.par_p3 * var1 * var1 / 16384 + cal.par_p2 * var1) / 524_288
    var1 = (1 + var1 / 32768) * cal.par_p1
    press_comp = 1_048_576 - raw_pressure
    press_comp = (press_comp - var2 / 4096) * 6250 / var1
    var1 = cal.par_p9 * press_comp * press_comp / 2_147_483_648
    var2 = press_comp * cal.par_p8 / 32768
    var3 = press_comp / 256 * press_comp / 256 * press_comp / 256 * cal.par_p10 / 131_072

    press_comp + (var1 + var2 + var3 + cal.par_p7 * 128) / 16
  end

  @spec raw_to_humidity(t(), number(), integer()) :: float()
  def raw_to_humidity(cal, temp, hum_adc) do
    var1 = hum_adc - (cal.par_h1 * 16 + cal.par_h3 / 2 * temp)

    var2 =
      var1 *
        (cal.par_h2 / 262_144 *
           (1 +
              cal.par_h4 / 16384 *
                temp + cal.par_h5 / 1_048_576 * temp * temp))

    var3 = cal.par_h6 / 16384
    var4 = cal.par_h7 / 2_097_152
    h = var2 + (var3 + var4 * temp) * var2 * var2

    min(100, max(0, h))
  end
end
