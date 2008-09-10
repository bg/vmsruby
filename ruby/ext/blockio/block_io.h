/*
 * Provide C wrapper functions for raw RMS I/O to files with fixed length
 * 512 byte block characteristics.  Files are accessed for shared access.
 *
 * Return values are the VMS condition codes returned by the applicable
 * system service.
 */

typedef struct rbi_context *rbi_p;	/* opaque to application */
typedef unsigned int rbi_bnum;		/* Virtual block number */
#define RBI_BLOCKSIZE 512

int rbi_open ( const char *fname, 	/* filename to open */
	int createif, 			/* create flag absent */
	rbi_p *rbi );			/* returns address of context block */
int rbi_close ( rbi_p rbi );

int rbi_get ( rbi_p rbi, rbi_bnum block_num, char block[RBI_BLOCKSIZE] );
int rbi_put ( rbi_p rbi, rbi_bnum block_num, char block[RBI_BLOCKSIZE] );
