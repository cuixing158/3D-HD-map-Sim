function logSensorSubFcn(timeStamp,location, orientation,bevImage,bevSemanticImage)
% Brief: 用于simulink matlab function模块的调用函数，记录传感器数据，便于C++使用其数据
% Details:
%    子函数，undefined function时候，可以独立为m文件使用
% 
% Syntax:  
%     logSensorSubFcn(timeStamp,egoVelocity,poseEgoInGlobalWorld,positionRotationEgoInGloableWorld,imgFrontSurround,imgRearSurround,imgLeftSurround,imgRightSurround,imageImgFrontWindshield,ultrasonicData)
% 
% Inputs:
%    timeStamp - [1,1] size,[double] type,Description
%    egoVelocity - [1,1] size,[double] type,Description
%    poseEgoInGlobalWorld - [1,3] size,[double] type,Description
%    positionRotationEgoInGloableWorld - [1,6] size,[double] type,Description
%    imgFrontSurround - [m,n] size,[None] type,Description
%    imgRearSurround - [m,n] size,[None] type,Description
%    imgLeftSurround - [m,n] size,[None] type,Description
%    imgRightSurround - [m,n] size,[None] type,Description
%    imageImgFrontWindshield - [M,N] size,[None] type,Description
%    ultrasonicData - [1,12] size,[double] type,Description
% 
% Outputs:
%    None
% 
% Example: 
%    None
% 
% See also: None

% Author:                          cuixingxing
% Email:                           cuixingxing150@gmail.com
% Created:                         26-Jul-2022 13:43:21
% Version history revision notes:
%                                  None
% Implementation In Matlab R2022a
% Copyright © 2022 TheMatrix.All Rights Reserved.
%
arguments
    % required
    timeStamp (1,1) double
   location
   orientation
    bevImage
    bevSemanticImage
end

% step1: initialize variables 
persistent numStep allTT 
if isempty(numStep)
    numStep = 1;
    timeStamp = duration(seconds(timeStamp));
    currTT = timetable(timeStamp,location,orientation);% corresponding to C++ mat2BinStruct type
    allTT = currTT;
else
    timeStamp = duration(seconds(timeStamp));
    currTT = timetable(timeStamp,location,orientation);% corresponding to C++ mat2BinStruct type
    allTT = [allTT;currTT];
end

% step2: write current images
img1Name = sprintf("./results/original/%05d.jpg",numStep);
img2Name = sprintf("./results/semantic/%05d.png",numStep);

imwrite(bevImage,img1Name);
imwrite(bevSemanticImage,img2Name);

% step3: write csv sensor data
writetimetable(allTT,"./results/sensorData.csv");

% step4: numStep plus one
numStep  = numStep+1;
end