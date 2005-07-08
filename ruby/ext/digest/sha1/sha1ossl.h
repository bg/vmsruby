/* $Id: sha1ossl.h,v 1.1 2002/09/26 17:44:33 knu Exp $ */

#ifndef SHA1OSSL_H_INCLUDED
#define SHA1OSSL_H_INCLUDED

#include <openssl/sha.h>

#define SHA1_CTX	SHA_CTX

#define SHA1_BLOCK_LENGTH	SHA_BLOCK_LENGTH
#define SHA1_DIGEST_LENGTH	SHA_DIGEST_LENGTH

char *SHA1_End(SHA1_CTX *ctx, char *buf);
int SHA1_Equal(SHA1_CTX *pctx1, SHA1_CTX *pctx2);

#endif
