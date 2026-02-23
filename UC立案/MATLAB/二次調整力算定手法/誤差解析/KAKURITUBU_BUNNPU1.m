function KAKURITUBU_BUNNPU1(fignum,data,color,hist_ox,L,sigma_num)
XY=size(data);
X=XY(1);Y=XY(2);
data=reshape(data,[X*Y,1]);
data = sort(data);
x_pdf = sort(data);
%% 正規分布
global pd
pd = fitdist(data,'Normal'); % Gammaもある
%% 確率密度関数
y = pdf(pd,x_pdf);
if ~exist('L', 'var') || isempty(L) %Lの指定がない場合
else
    y = y * length(data) / L;
end
line_data.y = y;
line_data.x = x_pdf;
line_data.data = data;
assignin('base','line_data',line_data);
assignin('caller','line_data',line_data);
%% plot
if hist_ox == 1
    h = histogram(data,'Normalization','probability');
    x=(h.BinEdges)-h.BinWidth/2;
    x=x(2:end);
    figure,bar(x,length(data).*(h.Values),1)
    hold on;line(x_pdf,y,'Color',color,'LineWidth',2)
end
end