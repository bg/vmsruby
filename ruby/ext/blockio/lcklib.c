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

static VALUE
lcklib_open(VALUE self, VALUE fname)
{
    int errCode,retVal;
    void *fptr;
    retVal=cRecordOpenFile(&fptr,&errCode,RSTRING(fname)->ptr,LCKMOD_READ,512);
    if(retVal == -1){
	rb_sys_fail(RSTRING(fname)->ptr);
    }
    /* FixMe: store fptr in an instance variable */
    /* return fptr; */
    return self;
}

static VALUE
lcklib_initialize(VALUE self)
{
    return self;
}

void
Init_Lcklib()
{
    VALUE Lcklib = rb_define_class("Lcklib", rb_cObject);
    rb_include_module(Lcklib, rb_mEnumerable);


    rb_define_method(Lcklib, "initialize", lcklib_initialize, 0);
    rb_define_singleton_method(Lcklib, "open", lcklib_open, 1);
/*    rb_define_method(Lcklib, "close", lcklib_close, 0);
    rb_define_method(Lcklib, "[]", lcklib_fetch, 1);

    id_lcklib = rb_intern("lcklib"); */
}

