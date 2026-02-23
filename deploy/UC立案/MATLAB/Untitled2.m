L=0;
for h=1:length(G_r_ox)
    s=size(nchoosek(G_r_ox,h));
    L=L+s(1);
end
Z=zeros(L,length(G_r_ox));
h_end=0;
for h=1:length(G_r_ox)
    s=size(nchoosek(G_r_ox,h));
    kumi=nchoosek(G_r_ox,h);
    for hh=1:s(1)
        hhh=h_end+hh;
        Z(hhh,1:length(kumi(hh,:)))=kumi(hh,:);
    end
    h_end=hhh;
end