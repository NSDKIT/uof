% -- 予測PV出力作成 --
run('予測PV出力作成/make_PV_forecast')
% -- 実PV出力作成 --
load(['PV実出力作成/PVO_mode',num2str(mode),'.mat'])
% -- based on 1100 --
E_D = [30,31,30,31,31,30,31-2,30,31,31,28,30].*86400;
PV_b=[820,840,930,960];m=0;
for iii=3:3:12
    if iii == 3
        PV_forecast_year(1:sum(E_D(1:3)))=...
            PV_forecast_year(1:sum(E_D(1:3)))*1100/PV_b(iii/3);
        PV_forecast_year_line(1:sum(E_D(1:3)))=...
                    PV_forecast_year_line(1:sum(E_D(1:3)))*1100/PV_b(iii/3);
        PV_Out(1:sum(E_D(1:3)))=...
                    PV_Out(1:sum(E_D(1:3)))*1100/PV_b(iii/3);
    else
        PV_forecast_year(sum(E_D(1:(iii-3)))+1:sum(E_D(1:iii)))=...
            PV_forecast_year(sum(E_D(1:(iii-3)))+1:sum(E_D(1:iii)))*1100/PV_b(iii/3);
        PV_forecast_year_line(sum(E_D(1:(iii-3)))+1:sum(E_D(1:iii)))=...
                    PV_forecast_year_line(sum(E_D(1:(iii-3)))+1:sum(E_D(1:iii)))*1100/PV_b(iii/3);
        PV_Out(sum(E_D(1:(iii-3)))+1:sum(E_D(1:iii)))=...
                    PV_Out(sum(E_D(1:(iii-3)))+1:sum(E_D(1:iii)))*1100/PV_b(iii/3);
    end
end
PV_forecast_year_line(86400*337+1:86400*338)=[];
PV_forecast_year(86400*337+1:86400*338)=[];
PV_Out(86400*337+1:86400*338)=[];

% -- 予測需要，実需要作成 --
run(['予測需要・実需要/make_Demand'])
Demand_real_year(86400*337+1:86400*338)=[];
Demand_year(86400*337+1:86400*338)=[];

PV_forecast_year_line=PV_forecast_year_line*k;
PV_forecast_year=PV_forecast_year*k;
PV_Out=PV_Out*k;

PV_forecast_year_line(find(PV_forecast_year_line>=10e4))=0;
PV_forecast_year(find(PV_forecast_year_line>=10e4))=0;
PV_Out(find(PV_Out>=10e4))=0;
% -- PV_Out vs PV_forecast_year --
% apply_pv_lowpass_filter
% -- PV_Out surplus --
% oxf=Demand_year>PV_forecast_year;
% oxo=Demand_real_year>PV_Out;
% PV_forecast_year=PV_forecast_year.*oxf+Demand_year.*(oxf==0);
% PV_Out=PV_Out.*oxo+Demand_real_year.*(oxo==0);