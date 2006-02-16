/*!
!!!======
!!!======
!!!
!!! Routine- REDIR by B. Coish             22-AUG-03 / ?INSTALL?
!!!
!!! Purpose-
!!!
!!!	Handling parsing of the ruby commandline to allow input/output 
!!!     redirection on VMS.
!!!
!!! Make-
!!!
!!!     LB REDIR
!!!
!!! Index-
!!!
!!!     Ruby redirection;
!!!
!!! Dymaxion Standard Version- 03
!!!
!!! Modifications-
!!!
!!!     03-SEP-03       BH / TH / TH   12=15647
!!!     - Created.
!!!
!!!     ?INSTALL?	BH/?WT?/?QA?   12=15647
!!!     - Fix redirection problem where redirection op contains
!!!       no spaces between op and operand. i.e. a>b
!!!     - Remove CharNext macro.
!!!
!!!======
!!!======
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


/* Constants used only by getRedirection */
enum { ERROR=-1,OK };
enum { REDIR_NONE, 
       REDIR_WRITE, 
       REDIR_APPEND, 
       REDIR_READ=4 };

/*!
   Purpose-
      Handle redirection from the ruby command line.

   Inputs-
      arg_c: number of arguments contained in argument vector - arg_v 
      arg_v: pointer to vector of argument values.

   Outputs-
      getRedirection: -1 on failure
                       0 on success

   Notes-
      Call this routine before any I/O actions in the main program to 
      ensure no output escapes redirection.
*/
int getRedirection(int *arg_c, char ***arg_v)
{
   char *input, *output;  /* Input and output file names */
   char *argPtr;          /* Pointer to current argument */
   int  direction;        /* Which redirection character */
   int  curArg=0;         /* Counter pointer for current argument */
   char openMode[2]={0};  /* Type of redirection determines destination */
                          /*   open mode.  i.e. >> == open mode "a" for append */
   int  hasRedir=0;       /* If redirection is not required don't return error, */
                          /*   just return */
   int  endOfCmdLine=0;   /* Index of the end of command line before first */
                          /*   redirection operator */
   int  argc=*arg_c;       
   char **argv=*arg_v;
   char **new_argv;       /* Used for rebuilding argv after setting up redirection */
   char *redirOpPos=NULL; /* Used for removing operator from argv input vector */
   char *temp;            /* Variable used as temporary place holder */
   int  count;
   input = output = NULL;
   direction=REDIR_NONE;

   /* Determine if redirection is requrired */
   for(curArg=0, argPtr=argv[curArg]; curArg < argc; curArg++, argPtr=argv[curArg]) {
      if(*argPtr == '>') {         
         /* Weed out multiple write redirections */
         if(((direction & REDIR_APPEND) == REDIR_APPEND) || 
            ((direction & REDIR_WRITE) == REDIR_WRITE)) {
            fprintf(stderr, "--> Only 1 output redirection permitted\n");
            return ERROR;
         }

         redirOpPos = argPtr;
            
         if(argPtr[1] == '>') {        /* Write redirection in append mode */
            direction |= REDIR_APPEND;
            if((argPtr[2] == '\0') && (curArg >= argc)) {
               fprintf(stderr, "--> Output redirection requires an output file\n");
               return ERROR;
            }
            output = (argPtr[2]) ? (argPtr+2) : argv[++curArg];
         } else { 
            if((argPtr[1] == '\0') && curArg >= argc) {
               fprintf(stderr, "--> Output redirection requires an output file\n");
               return ERROR;
            }           
            direction |= REDIR_WRITE;
            output = (argPtr[1]) ? (argPtr+1) : argv[++curArg];
         }         
         hasRedir = 1;
         *redirOpPos = '\0'; 
         redirOpPos = NULL;
      } else if(*argPtr == '<') {
         if(direction & REDIR_READ) {
            fprintf(stderr, "--> Only one input redirection permitted\n");
            return ERROR;
         }
         if((argPtr[1] == '\0') && curArg >= argc) {
            fprintf(stderr, "--> Input redirection requires an input file\n");
            return ERROR;
         }
         redirOpPos = argPtr;
         input = (argPtr[1]) ? (argPtr+1) : argv[++curArg];
         direction |= REDIR_READ;
         hasRedir = 1;
         *redirOpPos = '\0';
         redirOpPos = NULL;
      } else if((redirOpPos=strchr(argPtr,'<'))) {
         direction |= REDIR_READ;
         input = redirOpPos+1;
         *redirOpPos = NULL;
         hasRedir = 1;
      } else if(redirOpPos=strchr(argPtr,'>')) {
         if(*(redirOpPos+1) == '>') direction |= REDIR_APPEND;
         else direction |= REDIR_WRITE;
         if((direction & REDIR_APPEND) == REDIR_APPEND) {
            if(redirOpPos[2]) {
               output = redirOpPos+2;
               *(redirOpPos)=NULL; 
               *(redirOpPos+1)=NULL;
            } else {
               fprintf(stderr, "--> Append redirection requires an output file.\n");
               return ERROR; 
            }
         } else {
            if(redirOpPos[1]) {
               output = redirOpPos+1;
               *(redirOpPos)=NULL;
            } else {
               fprintf(stderr, "--> Output redirection requires an output file.\n");
               return ERROR;
            }
         }
         hasRedir = 1;
      }
   }
   
   /* Not having redirection is not an error, just return OK */ 
   if(!hasRedir) return OK; 
      
   if(direction & REDIR_WRITE) {
      openMode[0] = 'w';
   } else if(direction & REDIR_APPEND) {
      openMode[0] = 'a'; 
   } else if(direction & REDIR_NONE) {
      fprintf(stderr, "--> Unsupported redirection operation %d\n", direction);
      return ERROR;
   }

   /* Reopen stdin and stdout as the input and output files. */
   if( output ) {   /* Handle Write( > ) and Append( >> )*/
      if(!freopen(output, openMode, stdout, "mbc=32", "mbf=2")) { /* "rfm=stmlf")) {  "mbc=32", "mbf=2")) { */ 
         fprintf(stderr, "--> Unable to open output file [%s in mode %s]"
                         " for redirection\n", output,openMode);
         return ERROR;
      } 
      *output = '\0'; /* Remove output file from input vector */
   }

   if( input ) {                          /* Handle Read ( < ) */
      if(!freopen(input, "r", stdin,"mbc=32", "mbf=2")) {
         fprintf(stderr, "--> Unable to open input file [%s in mode %s] for redirection\n", output,openMode);
         return ERROR;
      }      
      *input = '\0';  /* Remove input file from input vector */
   }

   /* Rebuild command line with out redirection files and operators
      present,and pass it back to caller. */ 
   /* Enumerate arguments */
   for(curArg=0,count=0; curArg < argc; curArg++) {
      if(argv[curArg]) count++;
   }
  
   /* Copy arguments to the new command line vector */
   new_argv = (char**) calloc(count+1, sizeof(char*));
   for(curArg=0,count=0; curArg < argc; curArg++) {
      if(*argv[curArg]) new_argv[count++] = strdup(argv[curArg]);
   }

   /* Assign the new values for argv and argc. */
   arg_v = &new_argv;
   *arg_c = count;

   return OK;   
}
