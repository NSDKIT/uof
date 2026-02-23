% EDC_model = struct('mdl', cell(size(EDC_struct,1),size(EDC_struct,2), 1));
% for t = 1:size(EDC_struct,1)
%     for n = 1:size(EDC_struct,2)
%         ox=EDC_struct(t,n).data(1,:);
%         data=EDC_struct(t,n).data(2,:);
%         PV_data=pvf(t,:);
%         DEM_data=demf(t,:);
% 
%         if length(find(ox==0))~=length(ox)
%             data(find(ox==0))=[];
%             PV_data(find(ox==0))=[];
%             DEM_data(find(ox==0))=[];
%         end
% 
%         T = array2table([DEM_data',PV_data',data'],...
%             'VariableNames',{'DEM','PV','EDC'});
%         gprMdl = fitrgp(T,'EDC');
%         EDC_model(t, n, 1).mdl = gprMdl;
%     end
% end

LFC_model = struct('mdl', cell(size(LFC_struct,1),size(LFC_struct,2), 1));
for t = 1:size(EDC_struct,1)
    for n = 1:size(LFC_struct,2)
        ox=LFC_struct(t,n).data(1:1800,:);
        data=LFC_struct(t,n).data(1801:end,:);
        PV_data=PV_f(1800*(t-1)+1:1800*t,:);
        DEM_data=D_R_Y(1800*(t-1)+1:1800*t,:);

        data(find(ox==0))=[];
        PV_data(find(ox==0))=[];
        DEM_data(find(ox==0))=[];

        % Zスコアに基づく外れ値検出:
        z_scores = zscore(data);
        threshold = 3.0; % 閾値を設定
        outliers = abs(z_scores) > threshold; % 外れ値の検出
        
        data = data(find(outliers==0)); % 外れ値の検出
        PV_data = PV_data(find(outliers==0)); % 外れ値の検出
        DEM_data = DEM_data(find(outliers==0)); % 外れ値の検出

        % 1から100までの整数の一様ランダムなサンプルを生成
        nn = 10^4; % サンプル数を指定
        min_valu
        
        
        
        
        
        mkjjjjjje = 1;
        max_value = size(data,2);
        samples = randi([min_value, max_value], 1, nn);

        data = data(samples);
        PV_data = PV_data(samples);
        DEM_data = DEM_data(samples);

        T = array2table([DEM_data',PV_data',data'],...
            'VariableNames',{'DEM','PV','LFC'});
        gprMdl = fitrgp(T,'LFC');
        LFC_model(t, n, 1).mdl = gprMdl;
    end
end