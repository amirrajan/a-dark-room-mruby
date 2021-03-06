pkill adr-engine

cat ./app/debugging.rb > ./main_ruby.rb
cat ./app/cost_string.rb >> ./main_ruby.rb
cat ./app/stores.rb >> ./main_ruby.rb
cat ./app/crafts.rb >> ./main_ruby.rb
cat ./app/trades.rb >> ./main_ruby.rb
cat ./app/tools.rb >> ./main_ruby.rb
cat ./app/event.rb >> ./main_ruby.rb
cat ./app/world_event.rb >> ./main_ruby.rb
cat ./app/room_events.rb >> ./main_ruby.rb
cat ./app/outside_events.rb >> ./main_ruby.rb
cat ./app/encounter_events.rb >> ./main_ruby.rb
cat ./app/embark_events.rb >> ./main_ruby.rb
cat ./app/events.rb >> ./main_ruby.rb

cat ./app/incomes.rb >> ./main_ruby.rb
cat ./app/room.rb >> ./main_ruby.rb
cat ./app/outside.rb >> ./main_ruby.rb
cat ./app/game.rb >> ./main_ruby.rb
cat ./app/world.rb >> ./main_ruby.rb

cat ./tests/tests.rb >> ./main_ruby.rb
cat ./tests/crafting_tests.rb >> ./main_ruby.rb
cat ./tests/outside_tests.rb >> ./main_ruby.rb
cat ./tests/room_tests.rb >> ./main_ruby.rb
cat ./tests/income_tests.rb >> ./main_ruby.rb
cat ./tests/tools_tests.rb >> ./main_ruby.rb
cat ./tests/population_tests.rb >> ./main_ruby.rb
cat ./tests/thieves_tests.rb >> ./main_ruby.rb

./mruby/bin/mrbc -Bmain_ruby ./main_ruby.rb

clang main.c -I. \
      -I./mruby/include \
      -o./adr-engine -lmruby -L./mruby/build/host/lib

echo "compilation done"

./adr-engine

echo "tests complete"

touch ./.build-completed
