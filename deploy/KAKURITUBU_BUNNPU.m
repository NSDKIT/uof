function KAKURITUBU_BUNNPU(fignum,data,color,x_pdf,L,sigma_num)
%% ガンマ分布
% pd = fitdist(data,'Gamma');
% mu = pd.a*pd.b;
% sigma = pd.a*(pd.b^2);
% %% 確率密度関数
% y = pdf(pd,x_pdf);
% if ~exist('L', 'var') || isempty(L) %Lの指定がない場合
% else
%     y = y * length(data) / L;
% end
% % % plot
% figure(fignum)
% hold on
% % histogram(data,'Normalization','pdf')
% line(x_pdf,y,'Color',color)
k=0;
if k==1
%% 1シグマ塗りつぶし
if ~exist('sigma_num', 'var') || isempty(sigma_num) %Lの指定がない場合
    sigma_s = round(pd.mu-pd.sigma,2);
else
    sigma_s = round(mu-sigma_num*sigma,2);
end
sigma1_s = find(x_pdf==(fix(sigma_s)))+(sigma_s-fix(sigma_s))*100;
% if sigma_s<0
%     sigma1_s = 1;
% end
% if isempty(sigma1_s) == 1
%     sigma1_s = find(x_pdf==sigma_s+0.01);
%     if isempty(sigma1_s) == 1
%         sigma1_s = find(x_pdf==sigma_s-0.01);
%     end
% end

if ~exist('sigma_num', 'var') || isempty(sigma_num) %Lの指定がない場合
    sigma_e = round(pd.mu+pd.sigma,2);
else
    sigma_e = round(mu+sigma_num*sigma,2);
end
sigma1_e = find(x_pdf==(fix(sigma_e)))+(sigma_e-fix(sigma_e))*100;
% if isempty(sigma1_e) == 1
%     sigma1_e = find(x_pdf==sigma_e-0.01);
%     if isempty(sigma1_e) == 1
%         sigma1_e = find(x_pdf==sigma_e+0.01);
%         if isempty(sigma1_e) == 1 
%             sigma1_e = length(x_pdf);
%         end
%     else
%     end
% end
area(x_pdf(sigma1_s:sigma1_e),y(sigma1_s:sigma1_e),'FaceColor',color,'EdgeColor',color,'FaceAlpha',.1)
end
%% 正規分布
global sigma_s sigma_e
pd = fitdist(data,'Normal');
% pd.mu=0;
%% 確率密度関数
y = pdf(pd,x_pdf);
if ~exist('L', 'var') || isempty(L) %Lの指定がない場合
else
    y = y * length(data) / L;
end
%% plot
figure(fignum+10)
hold on
% histogram(data,'Normalization','pdf')
% histogram(data,40)
% yyaxis right
line(x_pdf,y,'Color',color,'LineWidth',1.5)
x_pdf(find(y==max(y)));
k=0;
if k==1
%% 1シグマ塗りつぶし
if ~exist('sigma_num', 'var') || isempty(sigma_num) %Lの指定がない場合
    sigma_s = round(pd.mu-pd.sigma,2);
else
    sigma_s = round(pd.mu-sigma_num*pd.sigma,2);
end
sigma1_s = find(x_pdf==(fix(sigma_s)))+(sigma_s-fix(sigma_s))*100;
% if sigma_s<0
%     sigma1_s = 1;
% end
% if isempty(sigma1_s) == 1
%     sigma1_s = find(x_pdf==sigma_s+0.01);
%     if isempty(sigma1_s) == 1
%         sigma1_s = find(x_pdf==sigma_s-0.01);
%     end
% end

if ~exist('sigma_num', 'var') || isempty(sigma_num) %Lの指定がない場合
    sigma_e = round(pd.mu+pd.sigma,2);
else
    sigma_e = round(pd.mu+sigma_num*pd.sigma,2);
end
sigma1_e = find(x_pdf==(fix(sigma_e)))+(sigma_e-fix(sigma_e))*100;
% if isempty(sigma1_e) == 1
%     sigma1_e = find(x_pdf==sigma_e-0.01);
%     if isempty(sigma1_e) == 1
%         sigma1_e = find(x_pdf==sigma_e+0.01);
%         if isempty(sigma1_e) == 1 
%             sigma1_e = length(x_pdf);
%         end
%     else
%     end
% end
area(x_pdf(sigma1_s:sigma1_e),y(sigma1_s:sigma1_e),'FaceColor',color,'EdgeColor',color,'FaceAlpha',.05)
% global sigma_data_s sigma_data_e
% sigma_data_s = x_pdf(sigma1_s);
% sigma_data_e = x_pdf(sigma1_e);
end
end