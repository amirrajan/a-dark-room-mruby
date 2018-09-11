pkill adr-engine

cat ./app/debugging.rb > ./main_ruby.rb
cat ./app/cost_string.rb >> ./main_ruby.rb
cat ./app/stores.rb >> ./main_ruby.rb
cat ./app/crafts.rb >> ./main_ruby.rb
cat ./app/trades.rb >> ./main_ruby.rb
cat ./app/tools.rb >> ./main_ruby.rb
cat ./app/incomes.rb >> ./main_ruby.rb
cat ./app/room.rb >> ./main_ruby.rb
cat ./app/outside.rb >> ./main_ruby.rb
cat ./app/game.rb >> ./main_ruby.rb
cat ./app/world.rb >> ./main_ruby.rb
cat ./app/tests.rb >> ./main_ruby.rb
cat ./app/crafting_tests.rb >> ./main_ruby.rb
cat ./app/outside_tests.rb >> ./main_ruby.rb
cat ./app/room_tests.rb >> ./main_ruby.rb
cat ./app/income_tests.rb >> ./main_ruby.rb

./mruby/bin/mrbc -Bmain_ruby ./main_ruby.rb

clang main.c -I. \
      -I./mruby/include \
      -o./adr-engine -lmruby -L./mruby/build/host/lib

echo "compilation done"

./adr-engine

echo "tests complete"

touch ./.build-completed
