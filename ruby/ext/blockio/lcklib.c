/**********************************************************************

  lcklib.c -

  $Author: bg $
  $Date: 2008/09/12 11:12:20 $

  All the files in this distribution are covered under the Ruby's
  license (see the file COPYING).

**********************************************************************/

#include "ruby.h"
#include "rubyio.h"
//#include "lcklib.h"

static VALUE lcklib_open _((VALUE));
static VALUE lcklib_initialize _((int, VALUE *, VALUE));
void Init_lcklib _((void));

static VALUE
lcklib_open(argc, argv, klass)
    int argc;
    VALUE *argv;
    VALUE klass;
{
    return Qnil;
}

static VALUE
lcklib_initialize(argc, argv, self)
    int argc;
    VALUE *argv;
    VALUE self;
{
    return self;
}

void
Init_lcklib()
{
    VALUE Lcklib = rb_define_class("Lcklib", rb_cData);

    rb_define_singleton_method(Lcklib, "open", lcklib_open, -1);
    rb_define_method(Lcklib, "initialize", lcklib_initialize, -1);
}
