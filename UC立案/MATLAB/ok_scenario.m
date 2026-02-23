hantei_a=hantei_off_time; % 停止しないといけない
hantei_a=find(hantei_a==0);
ok_num=[];
for i = hantei_a
    if isempty(ok_num)==1
        ok_num = 0;
    end
    ok_num=ok_num+(G_ox(:,i)==1);% 一つでも1があったらダメ
end
G_ox(find(ok_num~=0),:)=[];

hantei_a=find(hantei_on_time==0); % 起動しないといけない
ok_num=[];
for i = hantei_a
    if isempty(ok_num)==1
        ok_num = 1;
    end
    ok_num=ok_num.*(G_ox(:,i)==1);% 一つでも0があったらダメ
end
G_ox(find(ok_num==0),:)=[];

LFC_on_off=sum(G_ox(:,7:11)');
ok_num=find(LFC_on_off==0);
G_ox(ok_num,:)=[];

% Reserve_pos=(Rate_Min(1:11,1)-Rate_Min(1:11,2))'.*G_ox;
% Reserve_pos=sum(Reserve_pos');
% Reserve_nee=LFC_reserved_up(time)+EDC_reserved_plus(time);
% G_ox(find(Reserve_pos<round(Reserve_nee,1)),:)=[];