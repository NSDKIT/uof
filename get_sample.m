nn = 10^4; % サンプル数を指定
min_value = 1;
max_value = size(DF,1);
samples = randi([min_value, max_value], 1, nn);

DEMF=DEMF(samples);
PVOF=PVOF(samples);
NEER=NEER(samples);
LFCUSE=LFCUSE(samples);
RESSEC=RESSEC(samples);
DF=DF(samples);