min_output=[Rate_Min(1:4,2)',zeros(1,1),Rate_Min(5:10,2)',zeros(1,6),Rate_Min(11,2)',zeros(1,12)];
mode=UC_planning<min_output;
G_Out_o=G_Out(2:end,2:end);
g_mode=G_Out_o>=min_output;
G_Mode=zeros(88202,31);
G_Mode(2:end,1)=0:88200;
G_Mode(1,2:end)=1:30;
% -- 3: EDC, LFC対象機(Coal#3,4,5,6,LNG)
% -- 1: EDC対象, LFC非対象機(全Oil, Coal#1,2)
mode_base = [ones(1,4),0,ones(1,2),3*ones(1,4),zeros(1,6),3,zeros(1,12)];
g_mode=g_mode.*mode_base;
G_Mode(2:end,2:end)=g_mode;