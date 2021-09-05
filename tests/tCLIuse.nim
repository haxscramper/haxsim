import haxsim
import hmisc/other/oswrap

proc `@!`(str: string): seq[string] = @[str]

for (cmd, test) in {
  @!"lex", @!"parse", @!"typed", @!"eval": "print(\"123\");",
  @!"polish": "for i in [1] { print(i); }",
  @["eval", "--stack"]: "for i in [1] { print(i); }",
  @!"typed", @!"polish", @!"eval": """
var table = new Table;
var list = new List;
print(_bucket_count(table));
for i in [1, 2, 3, 4, 5, 6, 7, 8] {
  table[i] = i - 2 - 2 - 19 * (2 + (3 + (4 + 5 + 6 * 10)));
  add(list, i * 3 + 1);
}
print(table);
print(list);
print(_bucket_count(table));
""",
#   @!"eval": """
# for i in [1, 2, 3, 4, 5, 6, 7, 8] { add(list, i); }
# print(list);
# """,
  # @!"parse": "var z = test() + test2(1 + 3, 4) * 3 - 19 * (2 + (3 + (4 + 5 + 6 * 10)));"
}:
  echo "---", cmd
  echo test
  let file = writeTempFile(test)
  main(cmd & file.string)
  rmFile file
