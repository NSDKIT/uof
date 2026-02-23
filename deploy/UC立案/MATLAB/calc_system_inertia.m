TEIKAKU=[280,280,556,280,280,280,556,780,556,780,472];
inertia_i=8*ones(1,11);
% inertia_i=[7.70,7.70,8.56,7.70,7.70,7.70,9.86,6.81,7.25,6.86,6.83];
p_on=UC_planning>0;
inertia=sum((inertia_i.*TEIKAKU.*p_on)')/1000;
% -- 1秒値 --
Inertia=zeros(88202,2);
Inertia(2:end,1)=0:88200;
x = 0:0.5:24.5;xq_1min = 1/3600:1/3600:24.5;
v=inertia;
Inertia(2,2) = v(1);
Inertia(3:end,2) = interp1(x,v,xq_1min);
Inertia=[Inertia,Inertia(:,2)];