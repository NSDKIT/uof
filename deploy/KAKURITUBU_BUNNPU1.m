function KAKURITUBU_BUNNPU1(fignum,data,color,hist_ox,L,sigma_num)
XY=size(data);
X=XY(1);Y=XY(2);
data=reshape(data,[X*Y,1]);
data = sort(data);
x_pdf = sort(data);
%% 正規分布
global sigma_s sigma_e pd
pd = fitdist(data,'Normal'); % Gammaもある
%% 確率密度関数
y = pdf(pd,x_pdf);
if ~exist('L', 'var') || isempty(L) %Lの指定がない場合
else
    y = y * length(data) / L;
end
line_data.y = y;
line_data.x = x_pdf;
assignin('base','line_data',line_data);
assignin('caller','line_data',line_data);
%% plot
if isempty(fignum) == 0
    figure(fignum);hold on;line(x_pdf,y,'Color',color,'LineWidth',2)
    if hist_ox == 1
        yyaxis right
%         histogram(data,'Normalization','pdf')
        h = histogram(data,'Normalization','probability');
        
        x=(h.BinEdges)-h.BinWidth/2;
        x=x(2:end);
        figure,bar(x,length(data).*(h.Values),1)
        % histogram(data,8)
%         yyaxis left
    end
    k=0;
    if k==1
    %% 1シグマ塗りつぶし
    if ~exist('sigma_num', 'var') || isempty(sigma_num) %Lの指定がない場合
        sigma_s = round(pd.mu-pd.sigma,2);
    else
        sigma_s = round(pd.mu-sigma_num*pd.sigma,2);
    end
    sigma1_s = find(x_pdf==(fix(sigma_s)))+(sigma_s-fix(sigma_s))*100;
    if sigma_s<0
        sigma1_s = 1;
    end
    if isempty(sigma1_s) == 1
        sigma1_s = find(x_pdf==sigma_s+0.01);
        if isempty(sigma1_s) == 1
            sigma1_s = find(x_pdf==sigma_s-0.01);
        end
    end

    if ~exist('sigma_num', 'var') || isempty(sigma_num) %Lの指定がない場合
    %     sigma_e = round(pd.mu+pd.sigma,2);
        sigma_e = (pd.mu+pd.sigma);
    else
        sigma_e = round(pd.mu+sigma_num*pd.sigma,2);
    end
    sigma1_e = find(x_pdf==(fix(sigma_e)))+(sigma_e-fix(sigma_e))*100;
    if isempty(sigma1_e) == 1
        sigma1_e = find(x_pdf==sigma_e-0.01);
        if isempty(sigma1_e) == 1
            sigma1_e = find(x_pdf==sigma_e+0.01);
            if isempty(sigma1_e) == 1 
                sigma1_e = length(x_pdf);
            end
        else
        end
    end
    % area(x_pdf(sigma1_s:sigma1_e),y(sigma1_s:sigma1_e),'FaceColor',color,'EdgeColor',color,'FaceAlpha',.05)
    % global sigma_data_s sigma_data_e
    % sigma_data_s = x_pdf(sigma1_s);
    % sigma_data_e = x_pdf(sigma1_e);
    end
end
end