%% =========================================================
%  util_fit_normal_distribution.m  ―  正規分布フィッティングと確率密度関数の描画
% =========================================================
%
%  【役割】
%    与えられたデータに正規分布をフィッティングし、確率密度関数(PDF)を
%    指定された図番号にプロットする。
%    グローバル変数 sigma_s, sigma_e にσ範囲の下限・上限を返す。
%
%  【呼び出し方法】
%    util_fit_normal_distribution(fignum, data, color, x_pdf, L, sigma_num)
%
%  【引数】
%    fignum    : 描画先のfigure番号（整数）
%    data      : フィッティング対象のデータ配列
%    color     : プロット色（例: 'b', [0.2 0.4 0.8]）
%    x_pdf     : PDF を評価するx軸の範囲（例: [-15:0.01:15]）
%    L         : ヒストグラムとの重ね合わせ用スケール係数（空[]でデフォルト）
%    sigma_num : σの倍率（空[]で1σ）
%
%  【出力（グローバル変数）】
%    sigma_s   : σ範囲の下限値
%    sigma_e   : σ範囲の上限値
%    pd        : fitdist で得られた正規分布オブジェクト
%
%  【使用するスクリプト】
%    util_calc_sigma_per_band_basic.m  ― 各出力帯域のσ計算
%    step5_calc_sigma_basic.m          ― 全体のσ計算（mode1=2 のとき）
%    step5_calc_sigma_by_output_band.m ― 出力帯域別σ計算（mode1=2 のとき）
%
%  【注意事項】
%    - グローバル変数 sigma_s, sigma_e, pd を使用する。
%      呼び出し前に global 宣言が必要。
%    - σ塗りつぶし描画部分（k=1 ブロック）は現在無効化されている。
%    - 冒頭のガンマ分布ブロックはコメントアウト済み（参考として残存）。
% =========================================================

function util_fit_normal_distribution(fignum,data,color,x_pdf,L,sigma_num)
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
% sigma_s, sigma_e を計算して呼び出し元のワークスペースに返す
if ~exist('sigma_num', 'var') || isempty(sigma_num)
    sigma_s = round(pd.mu - pd.sigma, 2);
    sigma_e = round(pd.mu + pd.sigma, 2);
else
    sigma_s = round(pd.mu - sigma_num * pd.sigma, 2);
    sigma_e = round(pd.mu + sigma_num * pd.sigma, 2);
end
assignin('caller', 'sigma_s', sigma_s);
assignin('caller', 'sigma_e', sigma_e);
end