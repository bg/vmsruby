  /*
   !!!======
   !!!======
   !!!
   !!! Program- CLCKLIB.H by T.Hughes 02-SEP-09 / ?INSTALL?
   !!!
   !!! Purpose-
   !!!
   !!!	  C header for lcklib.hpp functions.
   !!!
   !!! Routines-
   !!!
   !!!	- See lcklib.hpp for documentation.
   !!!
   !!! Index-
   !!!
   !!!    C header for functions to control locking at a record level in files;
   !!!
   !!! Modifications-
   !!!
   !!!	?INSTALL? 	BH /?WT?/?QA?	12=
   !!!  - Revised lcklib.hpp to have a C compatible interface.
   !!!
   !!!======
   !!!======
*/

#ifndef __DYM_CLCKLIB_H__
#define __DYM_CLCKLIB_H__

#ifndef __DYM_LCKMOD_H__
#define __DYM_LCKMOD_H__
// Duplicated from LCKMOD.HPP
static const unsigned char LCKMOD_READ = 1;
static const unsigned char LCKMOD_WRITE_SH_NONE = 2;
static const unsigned char LCKMOD_WRITE_SH_READ = 4;
static const unsigned char LCKMOD_WRITE_SH_WRITE = 8;
#endif

#ifndef __DYM_LCKLIB_H__
#define __DYM_LCKLIB_H__

// Duplicated from LCKLIB.HPP
const int LCKLIB_CURRENT_RECORD = -1;
const int LCKLIB_STD_REC_SIZ = 512;

const int LCKLIB_OTHER = 0; 
const int LCKLIB_EOF = 1;
const int LCKLIB_ACCESS = 2;
const int LCKLIB_FNF = 3;

#endif

#ifndef __VMS
#include <io.h> // provides _sopen, _close
#include <fcntl.h>
#include <share.h>
#include <stdio.h>
#include <sys/stat.h>
#include <sys/locking.h>
#endif
#include <errno.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function prototypes */
int cRecordLock(void* pHandle, 
	        int* errorCode,
                long lRecordnumber, 
                char* pcBuffer, 
 	        long lRecordsize);
/*bh>
int cRecordLockMultiple ( void *pFile,
                          int* errorCode,
                          long lRecordNumber,
                          long lRecordCount,
                          long lRecordSize,
                          int noRead = 0);
*/
int cRecordRelease(void* pHandle,
		   int* errorCode, 
                   long lRecordnumber,
		   long lRecordsize);
/*bh>
int cRecordReleaseMultiple ( void *pFile,
                             int* errorCode,
                             long lRecordNumber,
                             long lRecordCount,
                             long lRecordSize);
*/
int cRecordGet(void* pHandle, 
	       int* errorCode,
               long lRecordnumber, 
               char* pcBuffer, 
	       long lRecordsize);
int cRecordPut(void* pHandle, 
	       int* errorCode,
               long lRecordnumber, 
               char* pcBuffer, 
               long lRecordsize);
int cRecordPutSequential(void* pHandle,
			 int* errorCode, 
                         char* pcBuffer, 
			 long lRecordsize);
int cRecordFlush(void* pHandle,
                 int* errorCode);
int cRecordOpenFile(void** fileHandle,
		    int* errorCode,
		    const char* pcFilename,
                    unsigned char mode,
		    long lRecordSize);
int cRecordCreateFile(void** fileHandle,
		      int* errorCode,
		      const char* pcFilename, 
		      unsigned char mode,
		      long lRecordSize);
int cRecordCreateOrOpenFile(void** fileHandle,
		            int* errorCode,
		            const char* pcFilename, 
                            unsigned char mode,
		            long lRecordSize);
int cRecordCloseFile(void* pFileHandle,
		     int* errorCode);

// System independant error decoding routine
int cRecordErr(int errorCode);

#ifdef __cplusplus
}
#endif

#endif /* __DYM_CLCKLIB_H__ */
