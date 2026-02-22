function sec_time_30min(day_range)
grid on
if day_range==1
    d_t=3;
else
    d_t=12;
end
xlim([1 48*day_range])
xticks(1:2*d_t:48*day_range)
xticklabels({'0:00','3:00','6:00','9:00','12:00','15:00','18:00','21:00','24:00',})
xlabel('時刻')
ylabel('')
end