%% 143色(RGB)
color = [
% red
255 0 0
% pink
205 92 92
% orenge
230 121 40
% oudo
186 132 72
% yellow
237 185 24
% black-green
84 135 34
% green
0 136 51
% black-blue
17 17 136
% blue-purple
0 0 255
% indigo
19 74 99
% purple
167 87 168
% red-purple
136 34 85
% gray
204 204 204
% black
225 225 225
];
color = color ./ 255;
% -- 13色 (PV,Thermal,Water) --
oil_color=flipud(turbo(10));
coal_color=gray(10);
water_color=cool(10);
mycolor_13 = [oil_color(4,:);
    oil_color(1:3,:);
    [170,134,66]/255;
    coal_color(3:8,:);
    [136,34,85]/255;
    water_color(1,:)];

%% 色の確認
% for num = 1:length(color)
%     figure(50)
%     hold on
%     plot(num*ones(1,5),'Color',color(num,:),'LineWidth',2)
% end