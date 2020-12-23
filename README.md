# estimatehydroperiod

1.	Purpose.    
The purpose of the model is to estimate the water depth and hydroperiod for a point of known elevation in the Ria Formosa lagoon.

2.	Model entities and definitions.    
This is a deterministic model that calculates the hydroperiod (hydp), defined as the cumulative time (hours) during which the point p is covered by water over a month. Hydroperiod is calculated using estimations of the water depth (dp,t) at a point p and time t, which are, in turn, based on the bed elevation (ep) at point p and the tide height (ht) at time t over 1-min intervals for a month. Hydroperiod can be also expressed as the % of the time in a month during which the point is underwater. The reference month used in this particular application of the model is March 2017, when the field study was conducted.

3.	Processes and overview of the code.     
First, the model interpolates, at intervals of 1 min and for a month, the tidal height based on the official tide chart for the closest reference port to the area where the hydroperiod is to estimate. For our study, we used the tide chart of Faro-Olhão from the Instituto Hidrográfico de Portugal (https://www.hidrografico.pt) for March 2017. Then, an analytical formula is used to calculate water depth based in the tide height at each time t and the elevation at point p:  depth (dp,t) = height (ht)- elevation (ep). The hydroperiod is calculated as the cumulative time over the month for which water depth is greater than 0.

4.	Inputs.    
The model requires two datasets as inputs:        
a)	data_tide.csv: Dataset with time and tide heights over a month (from official tide charts) for daily low and high tides. This is a csv file with three columns: time (YYYY-MM-DD, HH:MM), height (in m, referred to MSL), tide (factor with two levels: “low” and “high”). Note: the dataset must contain a row with the last tide of the previous month and the first tide of the following month.           
b)	data_points.csv: Dataset with points at which hydroperiod will be calculated. This is a csv file with at least two columns: point (unique id), elevation (in m, referred to MSL). It may contain other columns with information about those points (e.g. site, transect, habitat, waypoint, latitude, longitude).           

5.	Outputs.     
The model script generates the following outputs:     
a)	data_depths_minute.csv:  Dataset with with water depth at each point over a month at 1-m intervals.     
b)	table_hydroperiod_daily.csv: Dataset with daily hydroperiod at each point over a month.       
c)	table_hydroperiod_monthly.csv: Dataset with monthly hydroperiod at each point.        
d)	plots_hydroperiod_days.pdf: Plots showing the tide height over time (separated by day) for a month and per point. Each daily plot includes the time (h) of the day during which the point is emerged (E).       

6.	Validation and calibration.     
The modelled water depth was validated against field measurements of water depth at two points along the transect at site S3 (sampling points at 0 and 30 m) over two tidal cycles (28-29th March 2017). Water depth was measured with pressure transducers (Solinst ® Levelogger and In-Situ level troll) measuring at 4 Hz, after correction with their elevation from the bed.
