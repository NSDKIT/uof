function inter_line_86400(data0)
    l=length(data0);
    global data
    s=size(data0);
    data0=reshape(data0,[max(s),1]);
    data0=data0.*ones(min(s),1800);
    data=reshape(data0',[1,l*1800]);
    assignin('base','data',data)
    assignin('caller','data',data)
end