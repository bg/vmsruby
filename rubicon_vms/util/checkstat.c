/*************************************************************************
 *   checkstat.c		* <comment>
 *************************************************************************
 *
 * Description:
 *   Return stat informatoin on a file
 *
 *
 *************************************************************************
 * Copyright (c) 2000 The Pragmatic Programmers, LLC
 *************************************************************************/

#include <stdlib.h>
#include <sys/stat.h>
#ifndef _WIN32
#  include <unistd.h>
#endif
#include <stdio.h>
#include <errno.h>

int main(int argc, char **argv)
{
  int nargs = argc - 1;

  if (nargs == 1) {
    struct stat s;

    if (stat(argv[1], &s) != 0)
      exit(errno);

    printf("%d %d %d %d %d %d %d %d ",
           s.st_dev, s.st_ino, s.st_mode, s.st_nlink,
           s.st_uid,  s.st_gid, s.st_rdev, s.st_size);

#if defined(WIN32) || defined(__VMS)
    printf("-1 -1 ");
#else
    printf("%d %lld ", s.st_blksiz, (long long)s.st_blocks);
#endif

    printf("%ld %ld %ld\n",
           (long)s.st_atime, (long)s.st_mtime, (long)s.st_ctime);
  }
  else
    return -1;

  return 0;
}
