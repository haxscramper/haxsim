import haxsim/clexer
import std/[unittest]

suite "Base tokenizer":
  test "1":
    let tokens = tokenize("""
struct Test {
  long int zzz;
  long long int qqq;
};

for(int i = 0; i < 10; ++i) {
  puts("123");
  Test auql;
  auql.zzz;
}
""")
    for tok in tokens:
      echo tok.lispRepr()
