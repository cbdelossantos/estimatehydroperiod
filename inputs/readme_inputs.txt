data_heights.csv
.
- Source: Insituto Hidrográfico de Portugal (https://www.hidrografico.pt/).
- Data for March 2017, Faro-Olhao.
- Column height referenced to mean sea level (m MSL).
- Column height_zh referenced to hydrographic zero (m HZ).
- Column datetime_oficial_portugal: date time as shown in the official chart.
- Column time_zone: time zone for the datetime_official_portugal, WET or WEST.
- Column datetime in UTC (WET = UTC+0, WEST = UTC+1).
- Column tide: low or high tide.

data_points.csv

- Column point: ID for the points at which water depth over March and hydroperiod needs to be estimated.
- Column habitat: type of vegetation, Zn for Zostera noltei and Sm for Spartina maritima.
- Column latitude: UTM, in meters.
- Column longitude: UTM, in meters.
- Column elevation: elevation referred to mean sea level (m MSL).

data_depths.csv

Data used for the validation of the model.

- Column code: code for the transducer (PT2 and PT3 deployed at S3).
- Column point: ID of the point at which water level was measured: PT2 was placed at the lowest limit of the Zn bed (X: 22606.611 m Y: -296418.856 m E: -1.421 m) AND PT3 was placed at 30 m upwards from PT2 (X: 22577.854 m Y: -296410.770 m E: -0.596 m).
- Column datetime_recorded: date and time of the observation as recorded.
- Column time_zone: time zone for the datetime_recorded, Òhora de ver‹o de GMTÓ (i.e. WEST = UTC +1).
- Column datetime: date and time of the observation in UTC.
- Column raw_depth: water level measured with pressure transducers, referred to mean sea level (MSL, m).
- Column corrected_depth: water level measured with pressure transducers after correction, referred to mean sea level (MSL, m): depth corrected (PT2) Ð correction Ð 11 cm, depth corrected (PT3) Ð correction Ð 10 cm.
- Column depth: corrected water level after negative values were levelled to zero.




