#ifndef VMSRUBY_VMS_H_INCLUDED
#define VMSRUBY_VMS_H_INCLUDED

#include <time.h>

int rb_vms_select(int, fd_set*, fd_set*, fd_set*, struct timeval*); 
#define select(n, r, w, e, t) rb_vms_select(n, r, w, e, t)

extern int isinf(double);
extern int isnan(double);
extern int flock(int fd, int oper);

extern int vsnprintf();

/* For compatibility with pre-IPv6 TCP/IP stack on VMS (UCX < 5.3) */
#define sockaddr_storage sockaddr
#define HAVE_SOCKADDR_STORAGE 1

#ifdef INET6
#undef INET6
#endif

#endif
