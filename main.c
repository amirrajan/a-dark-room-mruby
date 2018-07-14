#include <mruby.h>
#include <mruby/irep.h>
#include "index.c"

int
main(void)
{
  mrb_state *mrb = mrb_open();
  mrb_load_irep(mrb, index);
  struct RClass *gameClass = mrb_class_get(mrb, "Game");
  mrb_value game = mrb_funcall(mrb, mrb_obj_value(gameClass), "new", 0);
  mrb_funcall(mrb, game, "hello_world", 0);
  mrb_close(mrb);
  return 0;
}
