function inter_86400(data)
    N_t=length(data);
    d_t=3600/2;
    v = data;
    x = 0:N_t-1; 
    xq = 1/d_t:1/d_t:N_t;
    data = interp1(x,v,xq);
    data(isnan(data))=0;
    assignin('base','data',data)
end