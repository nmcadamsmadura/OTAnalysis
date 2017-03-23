function [] = OT()   
format long g
uiwait(msgbox('Welcome to the program! Please select a .csv file with one excercise!','modal'));
filename = uigetfile;
t = importdata(filename);


gy = t.data(:,1) == 4;
gyroData = t.data(gy,1:4);
gyroData = abs(gyroData);


ac = t.data(:,1) == 3;
accelData = t.data(ac,1:4);
accelData = abs(accelData);

length(gyroData)
length(accelData)


size = min([length(gyroData);length(accelData)])
time = t.textdata(1:size);

fullsize = length (t.data(:,1));
accelLineStart = length(gyroData)+1;

tmp = zeros([2,3]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prompt = {'Enter Patient Name','How many sets did they do of this excercise?'};
dlg_title = 'Input';
num_lines = 1;
defaultans = {'<enter name>','<enter a number>'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Name','Angular Velocity X','units','normalized','position',[0 .5 .3 .3]);
plot(1:size,gyroData(1:size,2));
xlabel('Line #') % x-axis label
ylabel('Angular Velocity (X)') % y-axis label
grid on;
datacursormode on
set(gca, 'XTickLabel', num2str(get(gca, 'XTick')'));

figure('Name','Angular Velocity Y','units','normalized','position',[.3 .5 .3 .3]);
plot(1:size,gyroData(1:size,3));
xlabel('Line #') % x-axis label
ylabel('Angular Velocity (Y)') % y-axis label
grid on;
datacursormode on
set(gca, 'XTickLabel', num2str(get(gca, 'XTick')'));

figure('Name','Angular Velocity Z','units','normalized','position',[.6 .5 .3 .3]);
plot(1:size,gyroData(1:size,4));
xlabel('Line #') % x-axis label
ylabel('Angular Velocity (Z)') % y-axis label
grid on;
datacursormode on
set(gca, 'XTickLabel', num2str(get(gca, 'XTick')'));

figure('Name','Acceleration X','units','normalized','position',[0 .1 .3 .3]);
plot(1:size,accelData(1:size,2));
xlabel('Line #') % x-axis label
ylabel('Position') % y-axis label
grid on;
datacursormode on
set(gca, 'XTickLabel', num2str(get(gca, 'XTick')'));

figure('Name','Acceleration Y','units','normalized','position',[.3 .1 .3 .3]);
plot(1:size,accelData(1:size,3));
xlabel('Line #') % x-axis label
ylabel('Position') % y-axis label
grid on;
datacursormode on
set(gca, 'XTickLabel', num2str(get(gca, 'XTick')'));

figure('Name','Acceleration Z','units','normalized','position',[.6 .1 .3 .3]);
plot(1:size,accelData(1:size,4));
xlabel('Line #') % x-axis label
ylabel('Position') % y-axis label
grid on;
datacursormode on
set(gca, 'XTickLabel', num2str(get(gca, 'XTick')'));




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
answer2 = [];
options.WindowStyle = 'normal';
for i = 1:str2num(cell2mat(answer(2)))
prompt2 = {'Please enter the start and end times of sets',' '};
dlg_title2 = 'Input';
num_lines2 = 1;
defaultans2 = {'<enter a start number>','<enter a end number>'};
answer2 = [answer2; inputdlg(prompt2,dlg_title2,num_lines2,defaultans2, options)];
end
B = reshape(answer2,str2num(cell2mat(answer(2))),2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%{
ind = 1;
while ind ~= size
    tmp(1,1) = gyroData(ind,2);
    tmp(1,2) = gyroData(ind,3);
    tmp(1,3) = gyroData(ind,4);
    tmp(2,1) = gyroData(ind+1,2);
    tmp(2,2) = gyroData(ind+1,3);
    tmp(2,3) = gyroData(ind+1,4);
    DistanceAverage(ind) = ((tmp(2,1)-tmp(1,1))^2 + (tmp(2,2)-tmp(1,2))^2 + (tmp(2,3)-tmp(1,3))^2)^(1/2);
    ind = ind + 1;
end
averageDistancesPerSet = [];
cellAverage = [];
for i = 1:length(answer2)/2
 averageDistancesPerSet = DistanceAverage(str2num(B{i,1}):str2num(B{i,2})-1);
 cellAverage = [cellAverage;sum(averageDistancesPerSet)];
end 
averageDistance = cellAverage;
msg = cell(length(averageDistance),1);
%}

formatspec = ['Set %d\n\n', ... 
                    'Duration: ~ %d sec \n', ...
                    'Average angular velocity(x): %f deg/s \n',... 
                    'Average angular velocity(y): %f  deg/s \n',...
                    'Average angular velocity(z): %f  deg/s \n',...
                    'Total angular Velocity: %f deg/s \n',...
                    'Average acceleration(x): %f meters/s^2 \n',... 
                    'Average acceleration(y): %f meters/s^2 \n',...
                    'Average acceleration(z): %f meters/s^2 \n',...
                    'Total acceleration: %f \n'];
                


%Now we need to find the total duration of the time stamps
%To do this we need average time stops per minute.

initTime = char(time(str2num(B{1,1})));
timeWithoutChange = 0;
actualSeconds = [];
stops = [];
avgTS = [];
for i = 1:length(answer2)/2
    for k = str2num(B{i,1}):str2num(B{i,2});
        newTime = char(time(k));
        newTime2 = newTime(4:5);
        if str2num(newTime2) ~= str2num(initTime(4:5))
            stops = [stops; timeWithoutChange];
            initTime = char(time(k));
            timeWithoutChange = 0;
        else
            timeWithoutChange = timeWithoutChange + 1;
        end
    end
    actualSeconds = [actualSeconds; length(stops)]
    avgTS = [avgTS; round(mean(stops))];
end
averageTimeStopsPerSecond = avgTS

averageANG = [];
totalANG = [];
totalANG2 = [];
temp3 = 0;
for i = 1:length(answer2)/2
    for k = 1:length(avgTS)
        temp4 = str2num(B{i,1})+temp3;
        x = mean(gyroData(temp4:str2num(B{i,1}) + avgTS(k),2));
        y = mean(gyroData(temp4:str2num(B{i,1}) + avgTS(k),3));
        z = mean(gyroData(temp4:str2num(B{i,1})+ avgTS(k),4));
        total = x + y + z;
        totalANG = [totalANG; total];
        averageANG = [averageANG; x,y,z];
        temp3 = temp3 + str2num(B{i,1});
        
    end
    totalANG2 = [totalANG2;mean(totalANG)];
end

averageACC = [];
totalACC = [];
temp3 = 0;
for i = 1:length(answer2)/2
    for k = 1:length(avgTS)
        temp4 = str2num(B{i,1})+temp3;
        x = mean(accelData(temp4:str2num(B{i,1}) + avgTS(k),2));
        y = mean(accelData(temp4:str2num(B{i,1}) + avgTS(k),3));
        z = mean(accelData(temp4:str2num(B{i,1}) + avgTS(k),4));
        total = x + y + z;
        totalACC = [totalACC; total]; 
        averageACC = [averageACC; x,y,z];
        temp3 = temp3 + str2num(B{i,1});
    end
end

for i = 1:length(answer2)/2
   msg{i} = sprintf(formatspec,i,actualSeconds(i),averageANG(i,1),averageANG(i,2),averageANG(i,3),mean(totalANG2),averageACC(i,1),averageACC(i,2),averageACC(i,3),totalACC(i));
end
msgbox(msg);

    
    
end