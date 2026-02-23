load(fullfile(ROOT_DIR, 'meth_num.mat'))
switch meth_num
    case 1
        % 所要調整力算出用
        % RES=demand_30min'*.2+PVF_30min'*.5;
        % 静的手法
        RES=demand_30min'*.1+PVF_30min'*.25;
    otherwise
        switch meth_num
            case 2
                %% notXAI
                load('mdl_NotXAI_June0.mat')
                eva_data = array2table([DEMF_data,PVF_data,...
                    X1,X2,X3,X4,X5,X6,X7,X8,X9,X11],...
                    'VariableNames',{'DEMF_train','PVOF_train',...
                    'X1','X2','X3','X4','X5','X6','X7','X8','X9','X11'});

                % load('mdl_NotXAI_December.mat')
                % eva_data = array2table([X_t,DEMF_data,PVF_data,...
                %     X1,X2,X3,X4,X5,X6,X7,X8,X9,X11],...
                %     'VariableNames',{'t','DEMF_train','PVOF_train',...
                %     'X1','X2','X3','X4','X5','X6','X7','X8','X9','X11'});
            case 3
                % %% 論文だと method 3
                % % 6月：XAI2（PV，気温）
                % load('mdl_XAI_area1_June.mat')
                % eva_data = array2table([X_t,PVF_data,X5],...
                %     'VariableNames',{'t','PVOF_train','X5'});

                % 12月：XAI（PV）
                load('mdl_XAI_area1_December.mat')
                eva_data = array2table([X_t,PVF_data],...
                    'VariableNames',{'t','PVOF_train'});

            case 4
                %% 論文だと method 4
                % 6月：XAI（需要，PV，気温，下層，中層，上層雲量）
                % load('mdl_XAI_area13_June.mat')                
                % eva_data = array2table([X_t,DEMF_data,PVF_data,X5,X7,X8,X9],...
                %     'VariableNames',{'t','DEMF_train','PVOF_train','X5','X7','X8','X9'});

                % 12月：XAI（需要，PV，海面気圧，風速2種）
                load('mdl_XAI_area13_December.mat')
                eva_data = array2table([X_t,DEMF_data,PVF_data,X1,X3,X4],...
                    'VariableNames',{'t','DEMF_train','PVOF_train','X1','X3','X4'});
        end
        [yPred, yStd] = predict(gprMdl, eva_data);
        load(fullfile(ROOT_DIR, 'sigma.mat'))
        RES=yPred+sigma*yStd;
end
% figure(64);hold on;plot(RES)
% keyboard