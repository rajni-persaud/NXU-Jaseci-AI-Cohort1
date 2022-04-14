walker init{
    hr = 1;
    min = 120;

    while (min > 59){
        min = min - 60;
        hr = hr + 1;

        std.out(hr, min);
    }

    report [hr, min];
}