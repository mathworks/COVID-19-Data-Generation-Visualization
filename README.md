## COVID-19 Data Generation and Visualization Tool 
The package contains two functions func_dataGeneration.m (data
generation) and func_plotTrends.m (data visualization)

## Data Generation (func_dataGeneration.m)
The function leverages publicly available dataset maintained by the NY
Times, more details can be found at: https://github.com/nytimes/covid-19-data

The dataset will be downloaded to present working directory as a zip folder (master.zip), it will be unzipped to a directory named covid-19-data-master. By default this folder will be deleted at the conclusion of the function 

The function requires no input, will output for both states and counties 
(1) mat file including case and death numbers 
(2) excel file for case number 
(3) excel file for death number 

The naming convention for the files are date-month-year-state/county.mat 
and date-month-year-state/county-case.xlsx
and date-month-year-state/county-death.xlsx

## Data Visualization (func_plotTrends.m)
The function creates a GUI to ask user to select state or county or zip code to observe COVID-19 case and death trends 

The function requires the sorted data in date-month-year-state/county.mat generated from func_dataGeneration.m

The function has no required input but with the GUI guiding the user for inputs:
(1) National trend: the duration of data for analysis, number of days for moving average and user option to remove declining count (defaults to no data treatment, please see Notes #2 below)
(2) State: select state, the duration of data for analysis, number of days for moving average, and user option to remove declining count (defaults to no data treatment, please see Notes #2 below)
(3) County: the first input selection box asks for the state of interest; the second input box asks for the selection of county, the duration of data for analysis, number of days for moving average, and user option to remove declining count (defaults to no data treatment, please see Notes #2 below)
(4) Zip code: enter zip code, the duration of data for analysis, number of days for moving average, and user option to remove declining count (defaults to no data treatment, please see Notes #2 below)

The function also includes another function for creating the input selection box. This input selection box is powered by another File Exchange submission that can be found at https://www.mathworks.com/matlabcentral/fileexchange/25862-inputsdlg-enhanced-input-dialog-box

For simplicity, the input selection box function is embedded within func_plotTrends.m with acknowledgement; however, the user can choose to remove it within the function. To enable visualization, the user will need to download inputsdlg.m from the link above. 

The zip code option requires a dataset that associates zip code with state and country and this dataset is provided by the basic free version at: simplemaps.com/data/us-zips

The user will be asked to accept the download to the present working directory; the user can decline the download: the user will still be able to use the options of the state and county selection 

If the user acknowledges and accepts the download, the function downloads and unzips a zip file named simplemaps_uszips_basicv1.72.zip to a directory named simplemaps_uszips_basicv1.72. By default, this directory is NOT removed so the user can use the zip code option again next time. However, the user can remove it and the function will ask for permission to download again next time the user wants to use the zip code option. 

The function outputs figures of case and death trends.  

## Notes 
(1) Noted by the NY Times (https://github.com/nytimes/covid-19-data), declining counts can occur when a state or county corrects an error in the number of cases or deaths they've reported in the past, or when a state moves cases from one county to another. Functions provided here DO NOT detect and correct for such outliers 
(2) Please note the category of Unknown in the raw county data 

## Credit 
(1) Data is provided and maintained by the NY Times: https://github.com/nytimes/covid-19-data
(2) Input selection box is provided by Takeshi Ikuma and Luke Reisner at: https://www.mathworks.com/matlabcentral/fileexchange/25862-inputsdlg-enhanced-input-dialog-box
(3) Zip code data (if the user permits its usage), the basic/free version: simplemaps.com/data/us-zips