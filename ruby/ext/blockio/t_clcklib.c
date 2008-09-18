#define __USE_NON_ANSI_HEADERS
#include "clcklib.h"
#include <stdio.h>

void* do_open(const char* fname);

int main()
{
   char buf[512]={0};
   int errCode;
   void* in;

   in = do_open("[]dbgtext.txt");
   if(!in) return -1;

   if(cRecordGet(in, &errCode, (long)2, buf, 512)==-1) {
      fprintf(stderr, "-e-> Error(code=%d): recordGet\n",
              errCode); 
   }else {
      fprintf(stdout, "Successful recordGet.\nValue=%s\n", buf);
   } 

   cRecordCloseFile(in, &errCode);
   return 0;
}

void* do_open(const char* fname)
{
  int errCode,retVal;
  void *fptr;
  retVal=cRecordOpenFile(&fptr,&errCode,fname,LCKMOD_READ,512);
  if(retVal == -1){
     fprintf(stderr, 
            "-E-> Error opening file (code=%d)\n", errCode);
     return NULL;
  }
  return fptr;
}
