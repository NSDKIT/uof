EDC_reserved_plus=EDC_3sigma_n_plus';
EDC_reserved_plus=[EDC_reserved_plus,EDC_reserved_plus(end)*ones(1,2)];
EDC_reserved_plus(find(EDC_reserved_plus<0))=0;

EDC_reserved_minus=EDC_3sigma_n_minus';
EDC_reserved_minus=[EDC_reserved_minus,EDC_reserved_minus(end)*ones(1,2)];
EDC_reserved_minus(find(EDC_reserved_minus<0))=0;

LFC_reserved_up=LFC5_3sigma_n_up';
LFC_reserved_up=[LFC_reserved_up,LFC_reserved_up(end)*ones(1,2)];
LFC_reserved_up(find(LFC_reserved_up<0))=0;

LFC_reserved_down=LFC5_3sigma_n_down';
LFC_reserved_down=[LFC_reserved_down,LFC_reserved_down(end)*ones(1,2)];
LFC_reserved_down(find(LFC_reserved_down<0))=0;