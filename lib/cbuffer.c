#include "ruby.h"
#include <math.h>

/* CBuffer#initialize method, variable number of args */
static VALUE cInitialize(int argc, VALUE *args, VALUE self) 
{
  self = rb_call_super( argc, args );
  rb_iv_set(self, "@head", INT2NUM(0));
  rb_iv_set(self, "@mean", Qnil);
  rb_iv_set(self, "@sd", Qnil);
  
  return self;
}

/* CBuffer#statistics method, no args */
static VALUE cStatistics(VALUE self) 
{
  VALUE  size   = rb_funcall(self, rb_intern("size"), 0);
  VALUE  sum;
  VALUE  sd;
  int    c_size = NUM2INT(size);
  double c_sum  = 0.0;
  double c_sd   = 0.0;
  int    i;
  // Calculate mean
  for (i = 0; i < c_size; i++)
  {
    c_sum += NUM2DBL(rb_ary_entry(self, i));
  }
  c_sum /= c_size;
  // Calculate stdev
  for (i = 0; i < c_size; i++)
  {
    c_sd += pow((NUM2DBL(rb_ary_entry(self, i)) - c_sum), 2);
  }
  c_sd = sqrt(c_sd / (c_size - 1));
  // prepare result and stores ivs
  sum = rb_float_new(c_sum);
  sd  = rb_float_new(c_sd);
  rb_iv_set(self, "@mean", sum);
  rb_iv_set(self, "@sd", sd);
  
  return rb_ary_new3(2, sum, sd);
}

/* CBuffer#<<, takes one arg */
static VALUE cPush(VALUE self, VALUE obj) 
{
  int h    = NUM2INT(rb_iv_get(self, "@head"));
  int size = NUM2INT(rb_funcall(self, rb_intern("size"), 0));
  // Stores arg and rolls @head index
  rb_ary_store(self, h, obj);
  rb_iv_set(self, "@head", INT2NUM((h + 1) % size));
  rb_iv_set(self, "@mean", Qnil);
  rb_iv_set(self, "@sd", Qnil);
  
  return self;
}

/* CREATES THE EXTENSION */
// The class object declaration:
VALUE cBuffer;
// Links the callbacks:
void Init_CBuffer() 
{
  // Class object allocation:
  cBuffer = rb_define_class("CBuffer", rb_cArray);
  // Creates dynamic accessor methods:
  rb_define_attr( cBuffer, "head", 1, 1 );
  rb_define_attr( cBuffer, "mean", 1, 0 );
  rb_define_attr( cBuffer, "sd", 1, 0 );
  // links callbacks for instance methods:
  rb_define_method( cBuffer, "initialize", cInitialize, -1);
  rb_define_method( cBuffer, "statistics", cStatistics, 0);
  rb_define_method( cBuffer, "<<", cPush, 1);
}