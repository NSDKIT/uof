x = 0:0.5:24.5;xq_1min = 1/3600:1/3600:24.5;
G_Out=zeros(88202,31);
G_Out(2:end,1)=0:88200;
G_Out(1,2:end)=1:30;
for gen = 1:30
    v=UC_planning(:,gen);
    G_Out(2,gen+1) = v(1);
    G_Out(3:end,gen+1) = interp1(x,v,xq_1min);
end