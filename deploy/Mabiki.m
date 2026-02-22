function Mabiki(data,T,TT)
% T:全体の行数
% TT:求めたい行数
T1 = T/TT;
time0 = (data~=0);
global DATA Time
DATA = [];
Time = [];
for t = 1:T1
    d = mean(data(TT*(t-1)+1:TT*t));
    DATA = [DATA d];
    time = sum(time0(TT*(t-1)+1:TT*t))/1800;
    Time = [Time time];
end
end