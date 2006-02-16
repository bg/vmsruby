/**********************************************************************

  main.c -

  $Author: eban $
  $Date: 2004/10/31 16:06:57 $
  created at: Fri Aug 19 13:19:58 JST 1994

  Copyright (C) 1993-2003 Yukihiro Matsumoto

**********************************************************************/

#include "ruby.h"

#ifdef __human68k__
int _stacksize = 262144;
#endif

#if defined __MINGW32__
int _CRT_glob = 0;
#endif

#if defined(__MACOS__) && defined(__MWERKS__)
#include <console.h>
#endif

/* to link startup code with ObjC support */
#if (defined(__APPLE__) || defined(__NeXT__)) && defined(__MACH__)
static void objcdummyfunction( void ) { objc_msgSend(); }
#endif

#ifdef __VMS
extern int getRedirection(int *argc, char ***argv);
extern void VMSInitialize(int *argc, char ***argv);
#endif

/* Code is used to remove the -vnw (vms no wild) switch.
   which is used to signal not to expand wildcard arguments.
*/  
void remove_wildcard_shutoff(int *argc,char***argv) {
   char **new_arg_list;
   int cnt=0,ncnt=0;
   if(!argc || !argv) return;  
   if(*argc < 2) return;        /* too few arguments */

   /* Alloc new list */
   new_arg_list=(char*)malloc((*argc)*sizeof(char*));
   for(cnt=0,ncnt=0; cnt < *argc; cnt++) {
      if(strcasecmp(argv[0][cnt],"-vnw")) {
         new_arg_list[ncnt]=(char*)strdup(argv[0][cnt]);
         ncnt++;
      }
   }
   *argv=new_arg_list; 
   *argc=ncnt;
}


int
main(argc, argv, envp)
    int argc;
    char **argv, **envp;
{
int vmsi = 0;
#ifdef _WIN32
    NtInitialize(&argc, &argv);
#endif
#if defined(__MACOS__) && defined(__MWERKS__)
    argc = ccommand(&argv);
#endif
#if defined(__VMS)
# if 0
    if(argc > 1) {

    /* Hard wire switch to shut off command line wildcard processing. */
       if(strcasecmp(argv[1],"-vnw")==0) { /* vms no wild */
          remove_wildcard_shutoff(&argc,&argv);
       } else {
          VMSInitialize(&argc, &argv);
       }
    }
# endif
    if(getRedirection(&argc, &argv) != 0) {
       fprintf(stderr, "\nError initializing redirection\n");
    }
#endif
    ruby_init();
    ruby_options(argc, argv);
    ruby_run();
    return 0;
}
