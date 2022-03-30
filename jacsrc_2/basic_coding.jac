# This programs contains if statement and for loop
walker init {
    x = 34 - 30; # This is a comment
    y = "Hello";
    z = 3.45;

    if(z!=3.45 and y=="Bye"){
        x=x-1;
        y=y+" World"; # the + concatenates
    }
    std.out(x);
    i = 0;
    while (i<x){
        std.out(x-i,'-', y); # prints to screen
        i=i+1;
    }
    // for i=0 to i<3 by i+=1: # single line block
    //     std.out(x-i,'-', y); # prints to screen
    report [x, y+'s']; # adds data to payload
}