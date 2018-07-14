#include <mruby.h>
#include <mruby/variable.h>
#include <mruby/string.h>
#include <mruby/irep.h>
#include "index.c"
#include <stdio.h>

int
main(void)
{
  mrb_state *mrb = mrb_open();
  mrb_load_irep(mrb, index);
  struct RClass *testClass = mrb_class_get(mrb, "Tests");
  mrb_value tests =
    mrb_funcall(mrb,
		mrb_obj_value(testClass),
		"new",
		0);
  mrb_funcall(mrb,
	      tests,
	      "run",
	      0);

  if (mrb->exc) {
    mrb_value obj = mrb_funcall(mrb, mrb_obj_value(mrb->exc), "inspect", 0);
    fwrite(RSTRING_PTR(obj), RSTRING_LEN(obj), 1, stdout);
    putc('\n', stdout);
  }

  mrb_close(mrb);
  return 0;
}
