G_ox=[];
for n=1:11
    aa=nchoosek(1:11,n);
    s=size(aa);
    for m = 1:s(1)
        g_ox=zeros(1,11);
        g_ox(1,aa(m,:))=1;
        G_ox=[G_ox;g_ox];
    end
end