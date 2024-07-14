% 以下为通过编程接口方式控制RoadRunner仿真场景
% 但目前版本暂时无法通过编程方式获得roadrunner scenario车辆轨迹路径点坐标，改
% 用方法是RoadRunner Scene中的测量工具获取wayPoints3D,然后再导入到MATLAB中使用
% 
rrInstallationPath = "C:\Program Files\RoadRunner R2023b\bin\win64";
rrProjectPath = "E:\RoadRunner_work\myscene\New RoadRunner Project";

s = settings;
s.roadrunner.application.InstallationFolder.PersonalValue = rrInstallationPath;
rrApp = roadrunner(rrProjectPath);
openScenario(rrApp,"TrajectoryCutIn")
rrSim = createSimulation(rrApp);
simStepSize = 0.1;
set(rrSim,"StepSize",simStepSize);

set(rrSim,"SimulationCommand","Start")