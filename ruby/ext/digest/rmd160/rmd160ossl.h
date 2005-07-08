/* $Id: rmd160ossl.h,v 1.1 2002/09/26 17:26:46 knu Exp $ */

#ifndef RMD160OSSL_H_INCLUDED
#define RMD160OSSL_H_INCLUDED

#include <openssl/ripemd.h>

#define RMD160_CTX	RIPEMD160_CTX

#define RMD160_Init	RIPEMD160_Init
#define RMD160_Update	RIPEMD160_Update
#define RMD160_Final	RIPEMD160_Final

#define RMD160_BLOCK_LENGTH		RIPEMD160_CBLOCK
#define RMD160_DIGEST_LENGTH		RIPEMD160_DIGEST_LENGTH

char *RMD160_End(RMD160_CTX *ctx, char *buf);
int RMD160_Equal(RMD160_CTX *pctx1, RMD160_CTX *pctx2);

#endif
