with PolyORB.Initialization;
with PolyORB.POA_Config.RACWs;
with PolyORB.Setup.Thread_Pool_Server;

with CXE4002_Part_A1;
with CXE4002_Part_A2;
with CXE4002_A;

procedure Part1 is
begin
   PolyORB.Initialization.Initialize_World;
   CXE4002_A;
end Part1;
