%% 直接从RoadRunner Scene中的测量工具获取wayPoints3D,然后再导入到MATLAB中使用
% smoothPathSpline/waypointTrajectory函数进行平滑处理得到trajectory
% 参考：
% 1. Select Waypoints for Unreal Engine Simulation
% 2. Import RoadRunner Scene into Unreal Engine Using Simulink
% 注意：
% 由于仿真是调用的Unreal Engine，R2023b只能在windows上仿真查看结果，后续版本
% 支持win,linux,mac。
%
% 测试通过，效果较好

% waypoints是从roadrunner中鼠标选点得到的坐标，导入到simulink也是世界坐标点
isUseParkingGarage = 0; % 为1时使用simulinkParkGarage.slx，为0时使用simulinkPark.slx
if isUseParkingGarage % RoadRunner自带地下停车场路径控制点
    wayPoints3D = [-26.52,12.12,6.0;
        -26.70,-2.43,6.0;
        -21.16,-11.55,6.0;
        -18.17,-11.64,6.0;
        -2.10,-11.64,6.0;
        13.49,-11.57,6.0;
        17.66,-11.64,6.0;
        23.83,-7.15,6.0;
        26.23,-2.21,6.0;
        18.54,6.97,6.0;
        13.25,6.97,5.72;
        -14.93,7.19,3.72;
        -24.83,6.17,3.03;
        -28.26,1.48,3.0;
        -25.91,-9.49,3.0;
        -22.63,-11.71,3.0;
        -20.26,-11.65,3.0;
        16.41,-11.22,3.0;

        21.42,-10.17,3.0;
        26.49,-4.53,3.0;
        26.35,3.07,3.0;
        23.10,6.26,3.0;
        17.09,6.55,2.78;
        12.85,6.86,2.46;
        -12.17,7.72,0.53;
        -17.32,7.52,0.19;
        -26.52,10.17,0.0;
        -35.61,8.83,0.0];
    modelName = "simulinkParkGarage";
else %自己设计的一个回圈停车场
    wayPoints3D = [1.81,-29.07,0;
        5.9,14.61,0;
        11.63,22.09,0;
        41.11,21.10,0;
        50.27,12.05,0;
        50.52,-4.05,0;
        50.25,-50.45,0;
        44.18,-55.77,0;
        33.04,-55.77,0;
        4.55,-50.22,0;
        2.07,-46.23,0;
        1.53,-33.31,0;
        1.70,-31.25,0];
    modelName = "simulinkPark";
end
nums = size(wayPoints3D,1);

trajectory = waypointTrajectory(wayPoints3D,GroundSpeed=20*ones(nums,1));

% 以匀速17m/s进行前进，获得起始，终止时间点
t0 = trajectory.TimeOfArrival(1);
tf = trajectory.TimeOfArrival(end);

% 时间均匀采样，看每个点的ego vehicle姿态
sampleTimes = t0:1/60:tf; %取步长1/60是因为与Simulation 3D Scene Configuration一致，保障图像连续

[position,ori,velocity,acceleration,~] = lookupPose(trajectory,sampleTimes);
eul = quat2eul(ori);
yaw = rad2deg(eul(:,1));

% 拟传递给simulink的控制位姿
posX = [sampleTimes',position(:,1)];
posY = [sampleTimes',position(:,2)];
posYaw = [sampleTimes',yaw];

%
figure()
plot3(position(:,1),position(:,2),position(:,3),LineWidth=2)
hold on
plot3(wayPoints3D(:,1),wayPoints3D(:,2),wayPoints3D(:,3),'ro-',LineWidth=2)
xlabel("x (m)")
ylabel("y (m)")
zlabel("z (m)")
title("Trajectory")
legend(["trajectory","waypoints"])
grid on;

%% 3D仿真+地图映射

open_system(modelName);
set_param(gcs, 'StopTime', num2str(sampleTimes(end)));
sim(modelName)
close_system(modelName)



