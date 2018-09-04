#include <execinfo.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <mruby.h>
#include <mruby/variable.h>
#include <mruby/string.h>
#include <mruby/irep.h>
#include "main_ruby.c"

void handler(int sig)
{
  void *array[10];
  size_t size;
  size = backtrace(array, 10);
  fprintf(stderr, "Error: signal %d:\n", sig);
  backtrace_symbols_fd(array, size, STDERR_FILENO);
  exit(1);
}

int main()
{
  signal(SIGSEGV, handler);

  mrb_state *mrb = mrb_open();
  mrb_load_irep(mrb, main_ruby);
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
