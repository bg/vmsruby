#ifndef UTIME__H__
#define UTIME__H__

#include <stdlib.h>

struct utimbuf 
{
    time_t      actime;
    time_t      modtime;
} ;


int utime(const char *file_spec, const struct utimbuf *times);
#endif
