  /*
   !!!======
   !!!======
   !!!
   !!! Program- CLCKLIB.H by N. Proctor 20-JUL-00 /  2-AUG-02
   !!!
   !!! Purpose-
   !!!
   !!!    Functions to control locking at a record level in files.
   !!!	  NOTE: intended for internal use by the DymFil classes, please
   !!!	  use the interface provided in the DymFil classes for
   !!!	  application code.
   !!!
   !!! Routines-
   !!!
   !!!  int recordErr(int errorCode)
   !!!	   Purpose:
   !!!		Return system independant constant indicating 
   !!!		type of error that occurred.
   !!!	   Inputs:
   !!!		int errorCode
   !!!		- System dependant error code returned from one of
   !!!		  the record routines below.
   !!!	   Outputs:
   !!!		LCKLIB_EOF
   !!!		- Error is "file at EOF"
   !!!		LKCLIB_ACCESS
   !!!		- Error in attempt to access record.  VMS specific 
   !!!		  actual error codes will have more detail which
   !!!		  is unavailable on the windows variety.
   !!!		- Normal causes:
   !!!		  - Lock/Read/Put a record locked by another process
   !!!		  - Lock an already locked record (Windows only)
   !!!		  - PUT to a file you don't have write permission on
   !!!		  - OPEN a file you don't have permission to open
   !!!		  - Release a record locked by another process
   !!!		  - Release an already released record
   !!!		LCKLIB_FNF
   !!!		- Attempt to open a non-existing file
   !!!		LCKLIB_OTHER
   !!!		- A currently unclassified error
   !!!
   !!!	int recordLock(void* pHandle, int* errorCode, long lRecordnumber, 
   !!!		       char* pcBuffer, long lRecordsize)
   !!!	   Purpose:
   !!!		Attempts to acquire an exclusive lock on a record in the file
   !!!		represented by the file handle pHandle, and if successfull 
   !!!		reads the record from the file represented by the handle into 
   !!!          pcBuffer.
   !!!	   Inputs:
   !!!		void* pHandle
   !!!		- A pointer to a file handle to an open file.
   !!!		long lRecordnumber
   !!!		- Record number of the record you wish to lock.  
   !!!  	  Records start at 1.
   !!!		char* pcBuffer
   !!!		- pointer to a block of memory to contain the record.  Must be 
   !!!		 at least lRecordsize bytes in size!
   !!!		long lRecordsize
   !!!		- Number of bytes in a record.  Should also be the size of 
   !!!		pcBuffer. 
   !!!     Outputs:
   !!!		int* errorCode
   !!!		- The errno (NT) or RMS status (VMS) if an error occurred.
   !!!		  - NT
   !!!		    - EACCES: attempt to lock a locked record (NOTE:
   !!!		      record may be locked by the current process, in
   !!!		      which case it will be accessible).
   !!!		    - EBADF: attempt to read from an unopened file.
   !!!		    - 0 with recordLock == -1: file at EOF
   !!!		  - VMS
   !!!		    - RMS$_RLK: attempt to lock a record locked by another
   !!!		      process.  The VMS version does not error if an
   !!!		      attempt is made to re-lock a record locked by the
   !!!		      current process.
   !!!		    - RMS$_EOF: attempt to lock a record at EOF
   !!!		int recordLock
   !!!		- 0 = successful locking,
   !!!		- -1 = locking failed.
   !!!		  - Retrieve the reason from errorCode.  
   !!!	   Exceptions:
   !!!		Throws a const char* exception if pHandle is NULL.
   !!!	   Notes:
   !!!		- The record will remain locked and unavailable for writing and
   !!!		  reading by other processes until explicitly released by 
   !!!		  a call to  recordRelease or the file is closed.
   !!!		- Attempting to lock an already locked record fails
   !!!	   	  on Windows but will succeed on VMS if the record was
   !!!		  locked by the current process.
   !!!		- On windows, for files opened in read only mode, the record 
   !!!		  will be locked but the write will fail.
   !!!
   !!!	int cRecordRelease(void* pHandle, int* errorCode, long lRecordnumber, 
   !!!                    long lRecordsize)
   !!!	   Purpose:
   !!!		Release a lock on a record.
   !!!	   Inputs:
   !!!	      	void* pHandle
   !!!		- A pointer to a file handle to an open file.
   !!!		long lRecordnumber
   !!!		- Relative record number of the record you wish to unlock.  
   !!!		  Records start at 1. 
   !!!		long lRecordSize
   !!!		- Number of bytes in a record
   !!!	   Outputs:
   !!!		int* errorCode
   !!!		- The errno/RMS status if an error occurred.
   !!!		  - NT
   !!!		    - EACCES if you attempt to release an already released
   !!!		      record, OR attempt to release a record locked by
   !!!		      another process.
   !!!		    - EBADF if you attempt to read from an unopened file.
   !!!		  - VMS
   !!!		    - RMS$_RNL if you attempt to release an already
   !!!		      released record.
   !!!		    - RMS$_RLK: attempt to release a record locked by
   !!!		      another process.
   !!!		    - RMS$_EOF if you attempt to release a nonexistant record.
   !!!		int recordRelease
   !!!		- 0 if unlocking was successful
   !!!		- -1 if unlocking was unsuccessful.
   !!!	   Exceptions:
   !!!		Throws a const char* exception if pHandle is NULL.
   !!!	   Notes:
   !!!		- On VMS, when using WRITE_SH_NONE mode, nothing is
   !!!		  actualy locked even when a locking operation is requested.
   !!!		  Hence RecordRelease will always fail with RMS$_RNL.
   !!!
   !!!	int cRecordGet(void* pHandle, int* errorCode, long lRecordnumber, 
   !!!		      char* pcBuffer, long lRecordsize)
   !!!	   Purpose:
   !!!		Reads one record from the file into a buffer. The record
   !!!		must not be locked by another process. This function does
   !!!		not lock the record.  
   !!!	   Inputs:
   !!!		void* pHandle
   !!!		- A pointer to a file handle representing an open file.
   !!!		long lRecordnumber 
   !!!		- Record number of the record you wish to read.  
   !!!		  Records start at 1.
   !!!		char* pcBuffer
   !!!		- pointer to a block of memory to contain the record.  Must be 
   !!!		at least lRecordsize bytes in size!
   !!!		long lRecordsize
   !!!		- Number of bytes in a record.  Should also  be the size of 
   !!!		  pcBuffer.  
   !!!	   Outputs:
   !!!		int* errorCode
   !!!		- The errno/RMS status if recordGet failed.
   !!!		  - NT 
   !!!		    - EACCES: attempt to read a record locked by
   !!!		      another process.
   !!!		    - EBADF if you attempt to read from an unopened file.
   !!!		    - 0 (with recordGet == -1) if the file was at EOF.
   !!!		  - VMS 
   !!!		    - RMS$_RLK: attempt to read a record locked by 
   !!!		      another process.
   !!!		    - RMS$_EOF if the file was at EOF.
   !!!	 	cRecordGet
   !!!		- 0 = successful reading
   !!!		-1 = failed.
   !!!	 	  - Retrieve the reason from errorCode. 
   !!!	   Exceptions:
   !!!		Throws a const char* exception if pHandle is NULL.
   !!! 	   Notes:
   !!!		Reading will fail if the record is locked by another
   !!!		process.
   !!!
   !!!	int cRecordPut(void* pHandle, int* errorCode,long lRecordnumber, 
   !!!		char* pcBuffer, long lRecordsize)
   !!!	   Purpose:
   !!!		Writes one record from a buffer into a file.  This function
   !!!	        will lock the record first, if it is not already locked.  
   !!!
   !!!		If a lock was acquired automatically, it will be released, 
   !!!	        otherwise the record will remain locked.
   !!!	   Inputs:
   !!!		void* pHandle
   !!!		- A pointer to a file handle representing an open file.
   !!!		long lRecordnumber
   !!!		- relative record number of the record you wish to write to.  
   !!!		Records start at 1.
   !!!		char* pcBuffer
   !!!		- pointer to a block of memory containing the record.  Must be 
   !!!		  at least lRecordsize bytes in size!
   !!!		long lRecordsize
   !!!		- Number of bytes in a record.  Should also be the size of
   !!!		  pcBuffer. 
   !!!	   Outputs:
   !!!		int* errorCode
   !!!		- The errno/RMS status if an error occurred.
   !!!		  - NT
   !!!		    - EACCES: attempt to PUT to a record locked by
   !!!		      another process, or PUT to a file opened in
   !!!		      read-only mode.
   !!!		    - EBADF: attempt to read from an unopened file.
   !!!		  - VMS
   !!!		    - RMS$_RLK: attempt to PUT to a record locked by 
   !!!		      another process.
   !!!		    - RMS$_FAC: attempt to PUT to a file opened in
   !!!		      read-only mode.
   !!!		int recordPut
   !!!		- 0=successful writing
   !!!		 -1= writing failed.
   !!!	   Exceptions:
   !!!		Throws a const char* exception if pHandle is NULL.
   !!!	   Notes:
   !!!		- If the record is not already locked by the current process
   !!!		  recordPut obtains a lock before writing.
   !!!
   !!!	int cRecordPutSequential(void* pHandle, int* errorCode,
   !!!                          char* pcBuffer, long lRecordsize)
   !!!	   Purpose:
   !!!		Add a record to the end of a file. 
   !!!	   Inputs:
   !!!		void*  pHandle
   !!!		- A pointer to a file handle representing an open file.
   !!!	       	char* pcBuffer
   !!!		- pointer to a block of memory containing the record.  Must be 
   !!!		  at least lRecordsize bytes in size!
   !!!		long lRecordsize
   !!!		- the size in bytes of a record.  Should also be the size of 
   !!!		pcBuffer.
   !!!	   Outputs:
   !!!		int* errorCode
   !!!		- The errno/RMS status if an error occurred.
   !!!		  - NT
   !!!		    - EACCES: attempt to PUT to a record locked by another
   !!!		      process, or PUT to a file opened in read-only mode.
   !!!		      - May be caused by another process appending a
   !!!			record after the seek to EOF was done.
   !!!		    - EBADF: attempt to read from an unopened file.
   !!!		  - VMS
   !!!		    - RMS$_RLK: attempt to PUT to a record locked by 
   !!!		      another process.
   !!!		    - RMS$_FAC: attempt to PUT to a file opened in
   !!!		      read-only mode.
   !!!		    - RMS$_REX: record exists.  Occurs if another process
   !!!		      appended a record between the seek and the append
   !!!		      segments of this operation.
   !!!		int cRecordPutSequential
   !!!		- 0 if writing was successful
   !!!		-1 if writing failed.
   !!!	   Exceptions:
   !!!		Throws a const char* exception if pHandle is NULL.
   !!!	   Notes:
   !!!		- Since the seek to EOF and the subsequent put are
   !!!		  separate operations, the append may fail if another
   !!!		  process appended a record in between these operations.
   !!!		  The error will be RMS$_REX (record exists).
   !!!		- No lock will be retained after the function ends.
   !!!
   !!!	int cRecordOpenFile(void** fileHandle,int* errorCode,
   !!!			   const char* pcFilename,unsigned char mode,
   !!!			   long lRecordsize)
   !!!     Purpose:
   !!!		This function opens the EXISTING file named by pcFilename
   !!!		with the specified mode.  
   !!!	   Inputs:
   !!!		const char* pcFilename
   !!!		- Name of the file to be opened.
   !!!		unsigned char mode
   !!!		- Open modes defined in LCKMOD.H
   !!!		long lRecordsize
   !!!		- Size in bytes of a record
   !!!	   Outputs:
   !!!		int* errorCode
   !!!		- The errno/RMS status if an error occurred.
   !!!		  - NT
   !!!		    - ENOENT: attempt to open a nonexisting file.
   !!!		    - EACCES: attempt to open a file in a mode
   !!!		      you dont have permission for (eg. file is locked
   !!!		      by another process, or you don't have
   !!!		      read permissions on the file).
   !!!		    - 0 and recordCreateFile == -1: bad open mode.
   !!!		  - VMS
   !!!		    - RMS$_FNF: attempt to open a non-existing file.
   !!!		    - RMS$_FAC: attempt to open a file in a mode you
   !!!		      don't have permission for.
   !!!		    - RMS$_FLK: attempt to open a file that is locked
   !!!		      by another process.
   !!!		    - 0 and recordCreateFile == -1: bad open mode.
   !!!		void** fileHandle
   !!!		- A pointer to the file handle or RMS structure representing
   !!!		  the opened file.
   !!!		  - On VMS, this will be NULL if the open fails.
   !!!		int recordOpenFile
   !!!		- 0 if open was successful, -1 otherwise
   !!!	   Exceptions
   !!!		- Will throw a const char* exception if memory allocation
   !!!		  failed.
   !!!
   !!!	int cRecordCreateFile(void** fileHandle, int* errorCode,
   !!!		             const char* pcFilename, unsigned char mode,
   !!!			     long lRecordsize)
   !!!
   !!!	   Purpose:
   !!!		This function CREATES a new file named by pcFilename
   !!!		in sequential format.  If the file already exist then t
   !!!		the file is truncated to zero length.
   !!!	   Inputs:
   !!!		const char* pcFilename
   !!!		- Name of the file to be opened.
   !!!		unsigned char mode
   !!!		- Open modes defined in LCKMOD.H
   !!!		- The default open mode is LCKMOD_WRITE_SH_WRITE
   !!!		long lRecordSize
   !!!		- Size in bytes of records in the file.
   !!!	        - Default is LCKLIB_STD_REC_SIZ
   !!!	   Outputs:
   !!!		int* errorCode
   !!!		- The errno/RMS status if an error occurred.
   !!!		  - NT
   !!!		    - EACCES: attempt to open a file in a mode
   !!!		      you dont have permission for (eg. file is locked).
   !!!		    - 0 and recordCreateFile == -1: bad open mode.
   !!!		  - VMS
   !!!		    - RMS$_FAC: attempt to open a file in a mode you
   !!!		      don't have permission for.
   !!!		    - 0 and cRecordCreateFile == -1: bad open mode.
   !!!		void** fileHandle
   !!!		- A pointer to the file handle or RMS structure representing 
   !!!		  the created file.
   !!!		  - On VMS, this will be NULL if the create fails.
   !!!		int cRecordCreateFile
   !!!		- 0 if create was successful, -1 otherwise
   !!!	   Exceptions
   !!!		- Will throw a const char* exception if memory allocation
   !!!		  failed.
   !!!	   Notes:
   !!!		WARNING: IF the file exists it will be truncated to z
   !!!		zero length. 
   !!!
   !!!		(NT) The file will be created with an access mode (permissions 
   !!! 		settings) that allows other processes to read and write to it
   !!!
   !!!		(VMS) The file will be created with s:rwed o:rwed g:rwed
   !!!
   !!!	int cRecordCreateOrOpenFile(void** fileHandle, int* errorCode,
   !!!		             const char* pcFilename, unsigned char mode,
   !!!			     long lRecordsize)
   !!!
   !!!	   Purpose:
   !!!		This function CREATES a new file named by pcFilename
   !!!		in sequential format, or OPENS the file if it already
   !!!		exists.
   !!!	   Inputs:
   !!!		const char* pcFilename
   !!!		- Name of the file to be opened.
   !!!		unsigned char mode
   !!!		- Open modes defined in LCKMOD.H
   !!!		- Default is LCKMOD_WRITE_SH_WRITE.
   !!!		long lRecordSize
   !!!		- Size in bytes of records in the file.
   !!!	        - Default is LCKLIB_STD_REC_SIZ
   !!!	   Outputs:
   !!!		int* errorCode
   !!!		- The errno/RMS status if an error occurred.
   !!!		  - NT
   !!!		    - EACCES: attempt to open a file in a mode
   !!!		      you dont have permission for (eg. file is locked).
   !!!		    - 0 and cRecordCreateOrOpenFile == -1: bad open mode.
   !!!		  - VMS
   !!!		    - RMS$_FAC: attempt to open a file in a mode you
   !!!		      don't have permission for.
   !!!		    - RMS$_FLK: attempt to open a file that is locked
   !!!		      by another process.
   !!!		    - 0 and recordCreateOrOpenFile == -1: bad open mode.
   !!!		void** fileHandle
   !!!		- A pointer to the file handle or RMS structure representing 
   !!!		  the created/opened file.
   !!!		  - On VMS, this will be NULL if the create/open fails.
   !!!		int cRecordCreateOrOpenFile
   !!!		- 0 if create was successful, -1 otherwise
   !!!	   Exceptions
   !!!		- Will throw a const char* exception if memory allocation
   !!!		  failed.
   !!!	   Notes:
   !!!		The file will be created with an access mode (permissions 
   !!! 		settings) that allows other processes to read and write to it
   !!!
   !!!	int cRecordCloseFile(void* pFileHandle,int* errorCode)
   !!!	   Purpose:
   !!!		This function closes the file referenced by the file handle 
   !!!		pFileHandle.
   !!!	   Inputs:
   !!!		void* pFileHandle
   !!!		- Pointer to file handle representing the file to 
   !!!		  be closed.
   !!!	   Exceptions:
   !!!		Throws a const char* exception if pHandle is NULL.
   !!!	   Outputs:
   !!!		int* errorCode
   !!!		- The errno/RMS status if an error occurred.
   !!!		int cRecordCloseFile
   !!!		- 0 if file was successfully closed
   !!!  	-1 if file close was unsuccessful.
   !!!
   !!! Notes-
   !!!
   !!!	- There are 2 separate implementations of this library, one for
   !!! 	  windows and one for OpenVMS.
   !!!
   !!!	- errorCode is errno on Windows NT and the RMS status on OpenVMS.
   !!!	  - errno constants are available in <errno.h>
   !!!	  - RMS constants are available in <rmsdef.h>
   !!!
   !!!	- pHandle is a pointer to a filehandle on windows and a pointer
   !!!    to an RAB structure on OpenVMS.  In both cases, the Open and
   !!!    Create routine will allocate the structures for you, and the
   !!!    Close routine will delete the memory.  
   !!!
   !!!  - malloc is used for memory allocation.
   !!!
   !!!  - Record numbering starts at 1
   !!!
   !!!  - For decoding erroring conditions in a system independant
   !!!	  way, see cRecordErr();
   !!!
   !!!	Common OpenVMS RMS error codes:
   !!!
   !!!          RMS$_EOF        Record number beyond end of file.
   !!!          RMS$_FAC        File access error (ie. you don't have
   !!!                            permission to do the requested operation).
   !!!          RMS$_FLK        File locked (ie. you cannot open the
   !!!                            file in the requested mode)
   !!!          RMS$_RLK        Record locked.
   !!!          RMS$_RNL        Record not locked (recordRelease).
   !!!
   !!!
   !!!	Common errno error codes:
   !!!
   !!!		EACCES		
   !!!		- The file's permission setting does not allow the
   !!!		  specified access.
   !!!		EBADF
   !!!		- Bad file number
   !!!		ENOENT
   !!!		- No such file or directory.
   !!!
   !!! Index-
   !!!
   !!!    Functions to control locking at a record level in files;
   !!!
   !!! Modifications-
   !!!
   !!!	25-JUL-00       NP / TH / TH    12=12196
   !!!  - Created.
   !!!
   !!!	21-AUG-00	TH / NP / TH	12=12196
   !!!	- Add VMS specific notes to the header.
   !!!
   !!!	13-SEP-00	TH / ME / TH	12=12196
   !!!	- Add system independant error decoding routine, for when it
   !!!	  is important to determine the general class of error.
   !!!
   !!!	 2-AUG-02	TH / TG / TH 	12=14199
   !!!	- Update notes regarding changes caused by using raflib.
   !!!  - Add warning to recordPutSequential.
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
static const unsigned char LCKMOD_READ = 1;

// WARNING: on VMS, when in WRITE_SH_NONE mode, locking
// operations will not work.  They will on NT.  
//
// Note that whether or not locking operations work is irrelevant: in 
// LCKMOD_WRITE_SH_NONE mode the file may not be reopened by another 
// process (or even again by the same process) so there is no possible 
// conflict.  
//
// In LCKMOD_WRITE_SH_NONE mode, to prevent cross system differences, it
// is recommended locking not be done.  If it is done, be careful to
// handle the cross system differences in your error checking.  The only
// cross-system difference you will encounter is RecordRelease will
// error on VMS since the record was not actually locked.
//
static const unsigned char LCKMOD_WRITE_SH_NONE = 2;

static const unsigned char LCKMOD_WRITE_SH_READ = 4;
static const unsigned char LCKMOD_WRITE_SH_WRITE = 8;
#endif


#ifndef __DYM_LCKLIB_H__
// Default record to release for recordRelease
const int LCKLIB_CURRENT_RECORD = -1;

// Standard size of a record in a file created by LCKLIB.
const int LCKLIB_STD_REC_SIZ = 512;

// Returns from the system independant error routine
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
int cRecordRelease(void* pHandle,
		  int* errorCode, 
                  long lRecordnumber,
		  long lRecordsize);
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
