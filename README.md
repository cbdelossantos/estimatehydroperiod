## 1.	Purpose.    
The purpose of the model is to estimate the water depth and hydroperiod for a series of points of known elevation in the Ria Formosa lagoon (South Portugal) during a certain time period.     

## 2.	Model entities and definitions.    
This is a deterministic model that calculates the **hydroperiod (hydp)**, defined as the cumulative time (hours) during which the **point p** is covered by water over a month. Hydroperiod is calculated using estimations of the **water depth (dp,t) at a point p and time t**, which is, in turn, based on the **bed elevation (ep) at point p** and the **tide height (ht) at time t**, over 1-min intervals for a month (Figure 1, Table 1). Hydroperiod is also expressed as the % of the time in a month during which the point is underwater. The reference month used for the present application of the model was March 2017, when a field study was conducted (de los Santos et al., unpublished). The points of known elevation are located along cross-shore transects in the intertidal zone of four sites (S1 to S4) at the Ria Formosa lagoon, covering seagrass beds of *Zostera noltei* (Zn) and saltmarsh patches of *Spartina maritima* (Sm).     

## 3.	Processes and overview of the code.     
First, the model interpolates, at intervals of 1 min and for a month, the tidal height based on the official tide chart for the closest reference port to the area where the hydroperiod is to estimate. Then, an analytical formula is used to calculate water depth based in the tide height at each time t and the elevation at point p:  depth (dp,t) = height (ht)- elevation (ep). The hydroperiod is calculated as the cumulative time over the month for which water depth is greater than 0. In the present application, we used the tide chart of Faro-Olhão from the Instituto Hidrográfico de Portugal (https://www.hidrografico.pt) for March 2017. Tide heights from this chart are referred to the Hydrographical zero	(HZ), and were used in reference to the Mean Sea Level (MSL), using the formula MSL (m) = HZ (m) – 2.13.

## 4. Inputs.    
The model requires two datasets as inputs:        
*	**data_heights.csv**: Dataset with time and tide heights over a certain period of time for daily low and high tides. This is a csv file with three columns: datetime (YYYY-MM-DD, HH:MM), height (in m, referred to MSL), tide (factor with two levels: “low” and “high”). Note: the dataset must contain a row with the last tide of the previous month and the first tide of the following month. The model generates another csv file (data_heights_interpolated.csv) with the tide heights at 1-min intervals.              
*	**data_points.csv**: Dataset with points at which hydroperiod will be calculated. This is a csv file with at least two columns: point (unique id), elevation (in m, referred to MSL). It may contain other columns with information about those points (e.g. site, transect, habitat, waypoint, latitude, longitude).           

## 5. Outputs.     
The model script generates the following outputs:     
*	**data_depths_minute.csv**: Dataset with water depth (meters) at each point of known elevation over the specific time period at 1-min intervals.     
*	**table_hydroperiod_daily.csv**: Dataset with daily hydroperiod at each point of known elevation over the specific time period.       
*	**table_hydroperiod_monthly.csv**: Dataset with monthly hydroperiod at each point of known elevation over the specific time period.       
*	**table_hydroperiod_sampling_days.csv**: Dataset with hydroperiod at each point of known elevation over the specific time period of the field study.   
*	**plots_hydroperiod_days.pdf**: Plots showing the tide height over time (separated by day) for the specific time period and per point. Each daily plot includes the time (h) of the day during which the point is emerged (E).       

## 6.	Validation.     
The modelled water depth was validated against field measurements of water depth at two points along the transect at site S3 (sampling points at 0 and 30 m) over two tidal cycles (28-29th March 2017). Water depth was measured with pressure transducers (Solinst ® Levelogger and In-Situ level troll) measuring at 4 Hz, after correction with their elevation from the bed. The data for the validation is found in the file data_depth.csv in the folder inputs. 

**Table 1.** Entities used in the model.

| Name	| Abbr.	| Units	| Definition |
| --- | --- | --- | --- |
| Point	| p	| -	| Location for which bed elevation is known. Subscript. |
| Time	| t	| YYYY-MM-DD HH:MM	| Defined time at which water depth for point p to be determined. Subscript. |
| Bed elevation |	ep	| m MSL |	[INPUT] Distance from the bed to the datum at point p. Obtained from in situ measurements with a dGPS. |
| Tide height	| ht	| m MSL |[INPUT] Distance from the water surface to the datum at time t. Obtained from official tide charts. |
| Water depth	| dp,t	| m	| [OUTPUT] Distance from the water surface to the bottom at time t and at point p. |
| Hydroperiod |	hydp	| h month-1 OR h day-1 |[OUTPUT] Cumulative time (h) during which a point p is covered by water over a month or for a day. |
| Hydroperiod interval	| int	| min	| Time interval used for the calculation of the hydroperiod. This is the precision. Set at 1 minute. |
