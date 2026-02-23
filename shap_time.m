load('MSM_X.mat')
load('d.mat')
LOF=d1;PVF=d2;ERR=d3;RES=d4;
D=[LOF,PVF,X,RES];
D(find(isnan(D)))=0;
% %% 7:00～17:00までのみ抽出
D(:,[3:4,9:11,14])=[];
%     X=[];t_s=[0,24];
% for dd=1:28
%     % %%% 時間帯でサンプリング %%%
%     % X_end=max(D(86401*(dd-1)+1+[1800*t_s(1):1800*(t_s(2)+1)],end));
%     % X=[X;[D(86401*(dd-1)+1+[1800*t_s(1):1800*t_s(2)],1:end-1),X_end]];
%     %%% 1800秒断面でサンプリング %%%
%     X=[X;D(86401*(dd-1)+1+[3600*t_s(1):3600:3600*t_s(2)],:)];
% end
% S=[];
% R_X=max(abs(X));
% X=X./R_X;
% X=[1:size(X,2);X];
% csvwrite('data.csv',X)
% for num = 1:100
%     system('SHAP_exe.py')
%     shap=get_shap('shap.csv');
%     shap(:,[1,end])=[];
%     shap(isnan(shap))=[];
%     S(num,:)=shap;
% end
% figure,plot(S','o-')
%% 断面毎
T=1800;d_T=6;
for tt=24:6:42
    %%% 時間帯でサンプリング
    X=[];t_s=[tt,tt+d_T];
    for dd=1:29
        X=[X;[[T*t_s(1):T:T*t_s(2)]'/3600,D(86401*(dd-1)+1+[T*t_s(1):T:T*t_s(2)],1:end)]];
        % X_end=max(D(86401*(dd-1)+1+[T*t_s(1):T*(t_s(2)+1)],end));
        % X=[X;[D(86401*(dd-1)+1+[T*t_s(1):T*t_s(2)],1:end-1),X_end]];
    end
    % R_X=max(abs(X));
    % X=X./R_X;
    X(isnan(X))=0;
    X=[1:size(X,2);X];
    csvwrite('data.csv',X)
    S=[];
    for num = 1:10
        system('SHAP_exe.py')
        eval_y=get_shap('eval_y.csv');
        eval_y(:,[1,end])=[];eval_y=eval_y(1,:);eval_y(isnan(eval_y))=[];
        shap_values=get_shap('shap_values.csv');
        shap_values(:,[1,end])=[];
        nanColumns = any(isnan(shap_values), 1);
        shap_values = shap_values(:, ~nanColumns);
        summed_shap_values=get_shap('summed_shap_values.csv');
        summed_shap_values(:,[1,end])=[];
        nanColumns = any(isnan(summed_shap_values), 1);
        summed_shap_values = summed_shap_values(:, ~nanColumns);
        save(['S48_res_',num2str(tt),'-',num2str(num),'.mat'],'summed_shap_values','shap_values','eval_y')
        % shap(isnan(shap))=[];
        % shap=mean(reshape(shap,size(X,2)-1,[])');
        % S=[S;shap];
        S=[S;mean(shap_values','omitnan')];
        % S=[S;mean(((summed_shap_values-eval_y)./eval_y)'*100)];
    end
    save(['S48_res_',num2str(tt),'.mat'],'S')
    % copyfile('shap.csv',['shap_',num2str(tt),'.csv'])
end