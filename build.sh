pkill adr-endine

cat ./app/* > ./main_ruby.rb

./mruby/bin/mrbc -Bmain_ruby ./main_ruby.rb

clang main.c -I. \
      -I./mruby/include \
      -o./adr-engine -lmruby -L./mruby/build/host/lib

echo "compilation done"

./adr-engine

echo "tests complete"

touch ./.build-completed
