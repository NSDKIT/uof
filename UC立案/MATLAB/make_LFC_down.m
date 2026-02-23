LFC_capacity_t=abs(LFC_reserved_down(time));
LFC_capacity_down=[zeros(6,1);LFC_capacity_t*output_speed(LFC_gen,1)/sum(output_speed(LFC_gen,1))]; % 出力変化速度比率に応じて分配