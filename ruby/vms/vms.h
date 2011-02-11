#ifndef VMSRUBY_VMS_H_INCLUDED
#define VMSRUBY_VMS_H_INCLUDED

#include <time.h>

int rb_vms_select(int, fd_set*, fd_set*, fd_set*, struct timeval*); 
#define select(n, r, w, e, t) rb_vms_select(n, r, w, e, t)

extern int isinf(double);
extern int isnan(double);
extern int flock(int fd, int oper);

extern int vsnprintf();

#ifdef INET6
#undef INET6
#endif

typedef int socklen_t;

#endif
