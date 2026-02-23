ok_scenario
% if mm < 100
%     if time > 1
%         if PVF_30min(time)==0
%             G_ox=(UC_planning(time-1,:)>=Rate_Min(1:11,2)').*1;
%         end
%     end
% else
%     make_kumiawase
%     ok_scenario
% end