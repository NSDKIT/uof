function [d_uc_out, d_op_out, d_lfc_use, d_pv_error, d_lfc_use_30min, d_pv_error_30min, message_index] = analysis(filename)

    load(filename)

    try
        % 1sec data
        d_uc_out = sum(G_Out_UC(1:86401,:)');
        d_op_out = sum([Oil_Output,Coal_Output,Combine_Output]');
    
        d_lfc_use = d_op_out - d_uc_out;
        d_pv_error = PVF-PV_real_Output(2,:);

        % 30minutes data (横軸：時刻断面番号，縦軸：1800コマ（30分値））
        d_lfc_use_30min = max(reshape(d_lfc_use(1:end-1),1800,[]));
        d_pv_error_30min = d_pv_error(1:1800:end-1);
        message = '';
        message_index = 1;
    catch
        d_uc_out = [];
        d_op_out = [];
        d_lfc_use = [];
        d_pv_error = [];
        d_lfc_use_30min = [];
        d_pv_error_30min = [];
        message = 'AGC30モデルの都合上，解が発散しシミュレーションが86400秒出来なかった。';
        disp(message)
        message_index = 0;
    end

end