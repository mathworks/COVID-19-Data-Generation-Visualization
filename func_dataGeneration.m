function func_dataGeneration()
% FUNC_DATAGENERATION downloads publicly available COVID-19 data from the NY Times
% and generates sorted data (case and death) of states and counties for
% the accompanying plotting function func_plotTrends
%
% FUNC_DATAGENERATION() has no input requirement and outputs:
% (1) mat file including case and death numbers
% (2) excel file for case number
% (3) excel file for death number
% for both states and counties

%% Inform license 
licenseInterface();

end

%% License interface 
function licenseInterface()
%% The section below provides the user the opportunity to review the license
% The user may accept or decline license 
uifig = uifigure('Name','Data Download : Review and Confirm License');
strNote = ['By clicking Next and proceeding, you will be downloading and using a database ', ...
    'made available by The New York Times Company which may restrict use to non-commercial purposes'];
an = annotation(uifig, 'TextBox',[.15 .65 .7 .1],'String',strNote,'FontSize',18,...
    'FontWeight','bold','HorizontalAlignment','center',...
    'VerticalAlignment','top','margin',10,'LineStyle','none');
uiax = uiaxes(uifig,'Position',[0 0 uifig.Position(3:4)]);
uiax.Toolbar.Visible = 'off';
axis(uiax,'off')
th = text(uiax, .5, .32, ...
    '$\mathrm{\underline{License}}$',...
    'color',[0 0 .8],'FontSize',20,'Interpreter','latex',...
    'HorizontalAlignment','center',...
    'VerticalAlignment','middle');
th.ButtonDownFcn = @(~,~)web('https://github.com/nytimes/covid-19-data/blob/master/LICENSE'); % this opens the website
% Add OK button that closes figure
btnNext = uibutton(uifig,'push','Text','Next','Position',[160,50,75,30],...
    'ButtonPushedFcn',@(btnNext,event)btnNextFcn(btnNext,uiax,uifig));
btnDecline = uibutton(uifig,'push','Text','Cancel','Position',[320,50,75,30],...
    'ButtonPushedFcn',@(btnDecline,event)btnCancelFcn(btnDecline,uiax,uifig));
uiwait(uifig);
end

%% If license is accepted 
function btnNextFcn(btn,ax,uifig)
delete(uifig);
% If license is accepted 
acceptedLicense();
end

%% If license is declined 
function btnCancelFcn(btn,ax,uifig)
commandwindow;
disp('The program relies on the database provided by The New York Times');
disp('Unable to proceed');
delete(uifig);
end

%% Run data generation if license is accepted 
function acceptedLicense

commandwindow;

if exist('covid-19-data-master') == 7
    rmdir('covid-19-data-master','s');
end

fprintf('Downloading NY Times data from GitHub\nMore information at: github.com/nytimes/covid-19-data\n');
fprintf('<strong>Note: Data made available by The New York Times Company\n   may restrict use to non-commercial purposes </strong>\n');    if ~exist('covid-19-data-master','dir')
    websave('master.zip','https://github.com/nytimes/covid-19-data/archive/master.zip');
    unzip master.zip
    delete *.zip
end

fprintf('Done downloading NY Times data from GitHub\nMore information at: github.com/nytimes/covid-19-data\n');
fprintf('<strong>Note: Data made available by The New York Times Company\n   may restrict use to non-commercial purposes </strong>\n');

%% Generate data
t1 = clock;
func_data_state; % state data
t2 = clock;
disp(['Done with state data processing: ',num2str(etime(t2,t1)),' seconds']);
func_data_county; % county data
t3 = clock;
disp(['Done with county data processing: ',num2str(etime(t3,t2)),' seconds']);

%% Clean up
rmdir('covid-19-data-master','s');
end

%% Generate state data
function func_data_state

%% get raw data
t = datetime('today');
states = readtable(fullfile('covid-19-data-master','us-states.csv'));
time = table2array(states(:,1));
unqiuetime = unique(time);
statenames = table2array(states(:,2));
statestr = unique(statenames);
cases = table2array(states(:,4));
deaths = table2array(states(:,5));

%% preallocate based on the time frame that data are available
unique_time = unique(time);
min_time = min(unique_time);
cases_table = zeros(length(statestr),days(t - min_time) + 1);
deaths_table = zeros(length(statestr),days(t - min_time) + 1);

%% loop through all states
for i = 1:length(statestr)
    indx_state = find(strcmp(statenames,statestr(i)));
    time_state = time(indx_state);
    duration_state = days(t - time_state) + 1;
    cases_table(i, duration_state) = cases(indx_state);
    deaths_table(i, duration_state) = deaths(indx_state);
end

%% to sum across states
cases_table(end+1,:) = sum(cases_table);
deaths_table(end+1,:) = sum(deaths_table);

%% check if it's the weekend to remove recent zero reporting
zero_index = 0;
for i = 1:size(cases_table,2)
    if cases_table(end,i) == 0
        zero_index = i;
    else
        break;
    end
end

%% reverse the order so the earliest data appear first
cases_table = fliplr(cases_table(:,(zero_index+1):end));
deaths_table = fliplr(deaths_table(:,(zero_index+1):end));
timeline = unqiuetime(1:end-zero_index+1)';
statestr(end+1) = cellstr('U.S. Total');

%% generate table with proper notation
stateTable = table(statestr); stateTable.Properties.VariableNames = {'State'};
caseTable = array2table(cases_table,'VariableNames',string(timeline));
caseTable = [stateTable caseTable];
deathTable = array2table(deaths_table,'VariableNames',string(timeline));
deathTable = [stateTable deathTable];

%% save data
str_save = [char(t),'-state'];
writetable(caseTable,[str_save,'-case.xlsx']);
writetable(deathTable,[str_save,'-death.xlsx']);
save([str_save,'.mat'],'caseTable','deathTable');
end

%% Generate county data
function func_data_county

%% get raw data
t = datetime('today');
namedata = readtable(fullfile('covid-19-data-master','live','us-counties.csv'));
countyname = table2array(namedata(:,2));
statename = table2array(namedata(:,3));

%% process data
data = readtable(fullfile('covid-19-data-master','us-counties.csv'));
time = table2array(data(:,1));
unqiuetime = unique(time);
county = table2array(data(:,2));
state = table2array(data(:,3));
cases = table2array(data(:,5));
deaths = table2array(data(:,6));

%% preallocate
unique_time = unique(time);
min_time = min(unique_time);
cases_table = zeros(length(countyname),days(t - min_time) + 1);
deaths_table = zeros(length(countyname),days(t - min_time) + 1);

%% loop through the counties
f = waitbar(0, 'Starting');
set(f,'NumberTitle','off','Name', 'Processing county data');
for i = 1:length(countyname)
    indx_tmp = strcmp(county,countyname(i)) & strcmp(state,statename(i));
    indx = find(indx_tmp == 1);
    currentime = time(indx);
    duration_state = days(t - currentime) + 1;
    cases_table(i, duration_state) = cases(indx);
    deaths_table(i, duration_state) = deaths(indx);
    
    if mod(floor(i/length(countyname)*100),5) == 0
        waitbar(i/length(countyname), f, ...
            sprintf('Progress: %d %%', floor(i/length(countyname)*100)));
    end
    
end
delete(f); close all;

%% saving data set up
commandwindow
disp("Saving data, please wait for a few moments ...");

%% sum across all data
cases_table(end+1,:) = sum(cases_table);
deaths_table(end+1,:) = sum(deaths_table);

%% check recent 0 reporting in case it's the weekend
zero_index = 0;
for i = 1:size(cases_table,2)
    if cases_table(end,i) == 0
        zero_index = i;
    else
        break;
    end
end

%% reverse order
cases_table = fliplr(cases_table(:,(zero_index+1):end));
deaths_table = fliplr(deaths_table(:,(zero_index+1):end));
timeline = unqiuetime(1:end-zero_index+1)';
rownamedata = namedata(:,2:3);
rownamedata(end+1,1:2) = cellstr('U.S. Total');

%% proper notation
nameCountyTable = (rownamedata(:,1)); nameCountyTable.Properties.VariableNames = {'County'};
nameStateTable = (rownamedata(:,2)); nameStateTable.Properties.VariableNames = {'State'};
caseTable = array2table(cases_table,'VariableNames',string(timeline));
caseTable = [nameCountyTable nameStateTable caseTable];
deathTable = array2table(deaths_table,'VariableNames',string(timeline));
deathTable = [nameCountyTable nameStateTable deathTable];

%% save data
str_save = [char(t),'-county'];
writetable(caseTable,[str_save,'-case.xlsx']);
writetable(deathTable,[str_save,'-death.xlsx']);
save([str_save,'.mat'],'caseTable','deathTable');
end