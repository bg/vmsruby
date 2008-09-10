/**********************************************************************

  blockio.c -

  $Author: bg $
  $Date: 2008/01/16 13:50:00 $

  Based on example code from HP ITRC forum members.

  All the files in this distribution are covered under the Ruby's
  license (see the file COPYING).

**********************************************************************/

#include "ruby.h"
#include "rubyio.h"

/* #include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <lib$routines.h>
#include <ssdef.h>
#include <descrip.h>
#include <errno.h>
#include <unistd.h> */

#include "block_io.h"

struct BlockIO {
    VALUE string;
    long pos;
    long lineno;
    int flags;
    int count;
};

static struct BlockIO* blockio_alloc _((void));
static void blockio_mark _((struct BlockIO *));
static void blockio_free _((struct BlockIO *));
static struct BlockIO* check_blockio _((VALUE));
static struct BlockIO* get_blockio _((VALUE));

#define IS_BLOCKIO(obj) (RDATA(obj)->dmark ==(RUBY_DATA_FUNC)blockio_mark)


static struct BlockIO *
blockio_alloc()
{
    struct BlockIO *ptr = ALLOC(struct BlockIO);
    ptr->string = Qnil;
    ptr->pos = 0;
    ptr->lineno = 0;
    ptr->flags = 0;
    ptr->count = 1;
    return ptr;
}

static void
blockio_mark(ptr)
    struct BlockIO *ptr;
{
    if (ptr) {
        rb_gc_mark(ptr->string);
    }
}

static void
blockio_free(ptr)
    struct BlockIO *ptr;
{
    if (--ptr->count <= 0) {
        xfree(ptr);
    }
}

static struct BlockIO*
check_blockio(self)
    VALUE self;
{
    Check_Type(self, T_DATA);
    if (!IS_BLOCKIO(self)) {
        rb_raise(rb_eTypeError, "wrong argument type %s (expected BlockIO)",
                 rb_class2name(CLASS_OF(self)));
    }
    return DATA_PTR(self);
}

static struct BlockIO*
get_blockio(self)
    VALUE self;
{
    struct BlockIO *ptr = check_blockio(self);

    if (!ptr) {
        rb_raise(rb_eIOError, "uninitialized stream");
    }
    return ptr;
}

#define BlockIO(obj) get_blockio(obj)

static VALUE blockio_allocate _((VALUE));
static VALUE blockio_open _((int, VALUE *, VALUE));
static VALUE blockio_initialize _((int, VALUE *, VALUE));
static VALUE blockio_read _((int, VALUE *, VALUE));
void Init_blockio _((void));

static VALUE
blockio_allocate(klass)
    VALUE klass;
{
    return Data_Wrap_Struct(klass, blockio_mark, blockio_free, 0);
}

static VALUE
blockio_open(argc, argv, klass)
    int argc;
    VALUE *argv;
    VALUE klass;
{
    return Qnil;
}

static VALUE
blockio_initialize(argc, argv, self)
    int argc;
    VALUE *argv;
    VALUE self;
{
    return self;
}

static VALUE
blockio_read(argc, argv, self)
    int argc;
    VALUE *argv;
    VALUE self;
{
    return self;
}

void
Init_blockio()
{
    VALUE BlockIO = rb_define_class("BlockIO", rb_cData);

    rb_include_module(BlockIO, rb_mEnumerable);
    rb_define_alloc_func(BlockIO, blockio_allocate);
    rb_define_singleton_method(BlockIO, "open", blockio_open, -1);
    rb_define_method(BlockIO, "initialize", blockio_initialize, -1);
    rb_define_method(BlockIO, "read", blockio_read, -1);
}
