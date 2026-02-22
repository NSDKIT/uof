%% =========================================================
%  util_fit_normal_distribution_extended.m  ―  正規分布フィッティング（拡張版）
% =========================================================
%
%  【役割】
%    util_fit_normal_distribution の拡張版。
%    正規分布フィッティングとPDF描画に加え、ヒストグラムの重ね合わせ表示に対応。
%    計算結果（PDFのx・ y値）を line_data 構造体に格納し、
%    base/caller ワークスペースに返す。
%
%  【呼び出し方法】
%    util_fit_normal_distribution_extended(fignum, data, color, hist_ox, L, sigma_num)
%
%  【引数】
%    fignum    : 描画先のfigure番号（空[]の場合は描画しない）
%    data      : フィッティング対象のデータ配列
%    color     : プロット色（例: 'b', [0.2 0.4 0.8]）
%    hist_ox   : ヒストグラムを重ねて描画するか（1=描画, 0=描画しない）
%    L         : ヒストグラムとの重ね合わせ用スケール係数（空[]でデフォルト）
%    sigma_num : σの倍率（空[]で1σ）
%
%  【出力】
%    line_data.x : PDFのx値配列（baseおよびcallerワークスペースに返る）
%    line_data.y : PDFのy値配列
%    sigma_s     : σ範囲の下限値（グローバル変数）
%    sigma_e     : σ範囲の上限値（グローバル変数）
%    pd          : fitdist で得られた正規分布オブジェクト（グローバル変数）
%
%  【使用するスクリプト】
%    util_calc_sigma_per_band_extended.m  ― 出力帯域別σ計算（拡張版）
%    step5_calc_sigma_by_output_band.m    ― 出力帯域別σ計算（mode1=2 のとき）
%
%  【注意事項】
%    - グローバル変数 sigma_s, sigma_e, pd を使用する。
%      呼び出し前に global 宣言が必要。
%    - σ塗りつぶし描画部分（k=1 ブロック）は現在無効化されている。
% =========================================================

function util_fit_normal_distribution_extended(fignum,data,color,hist_ox,L,sigma_num)
XY=size(data);
X=XY(1);Y=XY(2);
data=reshape(data,[X*Y,1]);
data = sort(data);
x_pdf = sort(data);
%% 正規分布
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
% sigma_s, sigma_e, pd を呼び出し元のワークスペースに返す
if ~exist('sigma_num', 'var') || isempty(sigma_num)
    sigma_s = round(pd.mu - pd.sigma, 2);
    sigma_e = round(pd.mu + pd.sigma, 2);
else
    sigma_s = round(pd.mu - sigma_num * pd.sigma, 2);
    sigma_e = round(pd.mu + sigma_num * pd.sigma, 2);
end
assignin('caller', 'sigma_s', sigma_s);
assignin('caller', 'sigma_e', sigma_e);
assignin('caller', 'pd', pd);
end