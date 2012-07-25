#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"


MODULE = Mytest		PACKAGE = Mytest

void hello()
CODE:
     printf("Hello, world!\n");

int is_even(input)
    int input
    CODE:
    RETVAL = (input % 2 == 0);
    OUTPUT:
    RETVAL

void round(arg)
    double arg
    CODE:
    if (arg > 0.0) {
    arg = floor(arg + 0.5);
    } else if (arg < 0.0) {
    arg = ceil(arg - 0.5);
    } else {
    arg = 0.0;
    }
    OUTPUT:
    arg
