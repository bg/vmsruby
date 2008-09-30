/**********************************************************************

  lcklib.c -

  $Author: bg $
  $Date: 2008/09/12 11:12:20 $

  All the files in this distribution are covered under the Ruby's
  license (see the file COPYING).

**********************************************************************/

#include "ruby.h"
#include "rubyio.h"
#include "clcklib.h"

static VALUE rb_cLcklib, rb_eLcklibError;

struct lckdata {
    void *fptr;
};

#define GetLck(obj, lckp) {\
    Data_Get_Struct(obj, struct lckdata, lckp);\
    if (lckp == NULL) closed_lck();\
    if (lckp->fptr == NULL) closed_lck();\
}

static void
free_lck(lckp)
    struct lckdata *lckp;
{
    int errCode;

    if (lckp) {
	if (lckp->fptr) cRecordCloseFile(lckp->fptr, &errCode);
	free(lckp);
    }
}

static VALUE lcklib_alloc _((VALUE));
static VALUE
lcklib_alloc(klass)
    VALUE klass;
{
    return Data_Wrap_Struct(klass, 0, free_lck, 0);
}

static void
closed_lck()
{
    rb_raise(rb_eLcklibError, "attempted access to closed file");
}

static VALUE
lcklib_initialize(argc, argv, obj)
    int argc;
    VALUE *argv;
    VALUE obj;
{
    int errCode,retVal;
    struct lckdata *lckp;
    VALUE fname;
    void *fptr;
    
    rb_scan_args(argc, argv, "1", &fname);
    SafeStringValue(fname);

    retVal=cRecordOpenFile(&fptr,&errCode,RSTRING(fname)->ptr,LCKMOD_WRITE_SH_WRITE,LCKLIB_STD_REC_SIZ);

    if(retVal == -1){
        rb_raise(rb_eLcklibError, "could not open file: %s",RSTRING(fname)->ptr);
    }

    lckp = ALLOC(struct lckdata);
    lckp->fptr = fptr;
    DATA_PTR(obj) = lckp;

    return obj;
}

static VALUE
lcklib_s_open(argc, argv, klass)
    int argc;
    VALUE *argv;
    VALUE klass;
{
    VALUE obj = Data_Wrap_Struct(klass, 0, free_lck, 0);

    lcklib_initialize(argc, argv, obj);

    return obj;
}

static VALUE
lcklib_close(obj)
    VALUE obj;
{
    int errCode;
    struct lckdata *lckp;

    GetLck(obj, lckp);
    cRecordCloseFile(lckp->fptr, &errCode);
    lckp->fptr=NULL;

    return Qnil;
}

static VALUE
lcklib_get(obj, record)
    VALUE obj, record;
{
    char buf[LCKLIB_STD_REC_SIZ]={0};
    int errCode;
    struct lckdata *lckp;

    GetLck(obj, lckp);
    if (cRecordGet(lckp->fptr, &errCode, NUM2LONG(record), buf, LCKLIB_STD_REC_SIZ)==-1) {
        rb_raise(rb_eLcklibError, "could not get record: %d",NUM2LONG(record));
    }

    return rb_tainted_str_new(buf, LCKLIB_STD_REC_SIZ);
}

static VALUE
lcklib_get_locked(obj, record)
    VALUE obj, record;
{
    char buf[LCKLIB_STD_REC_SIZ]={0};
    int errCode;
    struct lckdata *lckp;

    GetLck(obj, lckp);
    if (cRecordLock(lckp->fptr, &errCode, NUM2LONG(record), buf, LCKLIB_STD_REC_SIZ)==-1) {
        rb_raise(rb_eLcklibError, "could not get record locked: %d",NUM2LONG(record));
    }

    return rb_tainted_str_new(buf, LCKLIB_STD_REC_SIZ);
}

static VALUE
lcklib_unlock(obj, record)
    VALUE obj, record;
{
    int errCode;
    struct lckdata *lckp;

    GetLck(obj, lckp);
    if (cRecordRelease(lckp->fptr, &errCode, NUM2LONG(record), LCKLIB_STD_REC_SIZ)==-1) {
        rb_raise(rb_eLcklibError, "could not unlock record: %d",NUM2LONG(record));
    }

    return Qnil;
}

static VALUE
lcklib_put(obj, record, buf)
    VALUE obj, record, buf;
{
    int errCode;
    struct lckdata *lckp;

    GetLck(obj, lckp);
    if (cRecordPut(lckp->fptr, &errCode, NUM2LONG(record), RSTRING(buf)->ptr, LCKLIB_STD_REC_SIZ)==-1) {
        rb_raise(rb_eLcklibError, "could not put record: %d",NUM2LONG(record));
    }

    return Qnil;
}

void
Init_Lcklib()
{
    rb_cLcklib = rb_define_class("Lcklib", rb_cObject);
    rb_eLcklibError = rb_define_class("LcklibError", rb_eStandardError);
    rb_include_module(rb_cLcklib, rb_mEnumerable);

    rb_define_alloc_func(rb_cLcklib, lcklib_alloc);

    rb_define_singleton_method(rb_cLcklib, "open", lcklib_s_open, -1);

    rb_define_method(rb_cLcklib, "initialize", lcklib_initialize, -1);
    rb_define_method(rb_cLcklib, "close", lcklib_close, 0);
    rb_define_method(rb_cLcklib, "get", lcklib_get, 1);
    rb_define_alias(rb_cLcklib, "[]", "get");
    rb_define_method(rb_cLcklib, "get_locked", lcklib_get_locked, 1);
    rb_define_method(rb_cLcklib, "unlock", lcklib_unlock, 1);
    rb_define_method(rb_cLcklib, "put", lcklib_put, 2);
}

