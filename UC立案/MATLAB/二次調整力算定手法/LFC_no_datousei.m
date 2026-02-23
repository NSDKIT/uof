KAKURITUBU_BUNNPU1([],data0,'b',1,[],[])

figure(14);subplot(N_gen,length(6:0.5:18),z)
hold on;histogram(line_data.x,'Normalization','probability');
xlim([-435.0000,435.0000])

g=gca;x=max(x,max(abs(g.XLim)));             % 全てのケースにおける最大のx軸の値を算出