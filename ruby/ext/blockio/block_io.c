/*
 * Provide C wrapper functions for raw RMS I/O to files with fixed length
 * 512 byte block characteristics.  Files are accessed for shared access.
 *
 * API summary:
 *    typedef <opaque> *rbi_p;
 *    int rbi_open ( const char *fname, int createif, rbi_p *rbi )
 *    int rbi_close ( rbi )
 *    int rbi_get ( rbi, rnum, block )
 *    int rbi_put ( rbi, rnum, block )
 *
 * Return values are the VMS condition codes returned by the applicable
 * system service.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <starlet.h>
#include <rms.h>
#include <ssdef.h>

#include "block_io.h"		/* validate prototypes in header */
/*
 * Context block for holding RMS control blocks.
 */
struct rbi_context {
    rbi_bnum cur_bnum;		/* Relative record number first rec. is 1 */

    struct FAB fab;		/* RMS file access block */
    struct RAB rab;		/* RMS record access block */
    char fname[1];		/* variable size, extended as needed */
};
/*****************************************************************************/
/* Functions to open and close a file.
 */
int rbi_open ( const char *fname, 	/* filename to open */
	int createif, 			/* create if absent flag */
	rbi_p *rbi_ret )		/* returns address of context block */
{
    rbi_p rbi;
    int nlen, status;
    /*
     * Allocate and initialize a context block.
     */
    nlen = strlen ( fname );
    if ( nlen > 255 ) return SS$_INVARG;	/* too long */
    rbi = malloc ( sizeof(struct rbi_context) + nlen );
    if ( !rbi ) return SS$_INSFMEM;
    *rbi_ret = rbi;
    strcpy ( rbi->fname, fname );

    rbi->fab = cc$rms_fab;	/* set to default values */
    rbi->rab = cc$rms_rab;
    /*
     * Open file, fixed length, 512 byte records.
     */
    rbi->fab.fab$b_fac = FAB$M_GET | FAB$M_PUT | FAB$M_UPD;
    rbi->fab.fab$l_fna = rbi->fname;		/* required field */
    rbi->fab.fab$b_fns = nlen;
    rbi->fab.fab$b_rfm = FAB$C_FIX;
    rbi->fab.fab$w_mrs = RBI_BLOCKSIZE;
    rbi->fab.fab$b_shr = FAB$M_SHRGET | FAB$M_SHRPUT | FAB$M_SHRUPD;
    rbi->fab.fab$b_org = FAB$C_SEQ;

    if ( createif ) {
	rbi->fab.fab$l_fop |= FAB$M_CIF;
	status = SYS$CREATE ( &rbi->fab, 0, 0 );
    } else {
	status = SYS$OPEN ( &rbi->fab, 0, 0 );
    }
    /*
     * Connect stream.
     */
    if ( status & 1 ) {
	rbi->rab.rab$l_fab = &rbi->fab;
	rbi->rab.rab$b_mbc = 64;
	rbi->rab.rab$l_rop = 0;

	status = SYS$CONNECT ( &rbi->rab, 0, 0 );
 	if ( (status&1) == 0 ) printf ( "connect of stream failed: %d\n",status);
    } else {
	printf ( "%s failed\n", createif ? "create" : "open" );
    }

    if ( (status&1) == 0 ) free ( rbi );
    return status;
}

int rbi_close ( rbi_p rbi )
{
    int status;
    rbi->fab.fab$l_fop = 0;
    status = SYS$CLOSE ( &rbi->fab, 0, 0 );

    free ( rbi );
    return status;
}
/*
 * Set RAB for random access to specified block number using specified options.
 */
static void set_key ( rbi_p rbi, rbi_bnum block_num, int rec_opt )
{
    rbi->rab.rab$l_kbf = (char *) &rbi->cur_bnum;
    rbi->rab.rab$b_ksz = sizeof(rbi->cur_bnum);
    rbi->rab.rab$b_rac = RAB$C_KEY;
    rbi->rab.rab$l_rop = rec_opt;
    rbi->cur_bnum = block_num;
}
/*****************************************************************************/
/* Read and write the fixed length record at an arbitrary location.
 */
int rbi_get ( rbi_p rbi, rbi_bnum block_num, char block[RBI_BLOCKSIZE] )
{
    int status;
    rbi->rab.rab$l_ubf = block;
    rbi->rab.rab$w_usz = RBI_BLOCKSIZE;
    set_key ( rbi, block_num, RAB$M_WAT |RAB$M_REA );

    status = SYS$GET ( &rbi->rab, 0, 0 );

    if ( status&1 ) status = SYS$RELEASE ( &rbi->rab, 0, 0 );

    return status;
}
int rbi_put ( rbi_p rbi, rbi_bnum block_num, char block[RBI_BLOCKSIZE] )
{
    int status;
    rbi->rab.rab$l_rbf = block;
    rbi->rab.rab$w_rsz = RBI_BLOCKSIZE;
    set_key ( rbi, block_num, RAB$M_WAT | RAB$M_UIF );

    return SYS$PUT ( &rbi->rab, 0, 0 );
}
