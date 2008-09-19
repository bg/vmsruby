/**********************************************************************

  lcklib.c -

  $Author: bg $
  $Date: 2008/09/12 11:12:20 $

  All the files in this distribution are covered under the Ruby's
  license (see the file COPYING).

**********************************************************************/

#include "ruby.h"
/* #include "lcklib.h" */

static VALUE
lcklib_open(VALUE self, VALUE obj)
{
    return Qnil;
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

    rb_define_method(Lcklib, "initialize", lcklib_initialize, 0);
}
