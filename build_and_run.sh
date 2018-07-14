cat ./app/* > ./index.rb
mrbc -Bindex ./index.rb
gcc -std=c99 -I../mruby/include main.c -o main ../mruby/build/host/lib/libmruby.a -lm
echo "done"
./main
echo "tests complete"
