# ExDoukaku

[横浜へなちょこプログラミング勉強会](https://yhpg.doorkeeper.jp) で出題される「オフラインリアルタイムどう書く」の Elixir の実行環境を用意するパッケージです。

## インストール

`mix.exs` に `ex_doukaku` を追加します。

```elixir
def deps do
  [
    {:ex_doukaku, github: "mattsan/ex_doukaku"}
  ]
end
```

パッケージを取得しコンパイルします。

```
$ mix do deps.get, deps.compile
```

## 雛形の生成

コマンド `mix doukaku.new` で雛形を生成します。

```
$ mix doukaku.new
* creating lib/sample/test_runner.ex
* creating lib/sample/solver.ex
```

`test_runner.ex` と `solver.ex` が作成されます

```elixir
defmodule Sample.TestRunner do
  use ExDoukaku.TestRunner, solver: [Sample.Solver, :solve]

  c_styled_test_data """
    /* 0 */ test("abc", "abc");
  """
end
```

```elixir
defmodule Sample.Solver do
  def solve(input) do
    input
  end
end
```

提供されるテストデータを `test_runner.ex` の `c_styled_test_data` に貼り付けます。

## 実行

コマンド `mix doukaku.test` でテストを実行します。

```
$ mix doukaku.test
Compiling 3 files (.ex)
Generated sample app
   0: passed

Finished in 0.5 seconds
```

テストに失敗した場合は入力と結果を表示します。

例として `test_runner.ex` の `c_styled_test_data` を次のように編集します。

```elixir
  c_styled_test_data """
    /* 0 */ test("abc", "abc");
    /* 1 */ test("def", "abc");
  """
```

```
$ mix doukaku.test
Compiling 1 file (.ex)
   0: passed
   1: failed  input: 'def'  expected: 'abc'  actual: 'def'

Finished in 0.04 seconds
```

### 実行するテストを指定する

オプション `--number` ( `-n` ) で実行するテストを指定できます。

```
$ mix doukaku.test -n 0
   0: passed

Finished in 0.1 seconds
```

複数のテストを指定することもできます。その場合はコンマか空白で区切ります。空白の場合は引用符で囲んでください。

```
$ mix doukaku.test -n 0,1
   0: passed
   1: failed  input: 'def'  expected: 'abc'  actual: 'def'

Finished in 0.1 seconds
```

```
$ mix doukaku.test -n "0 1"
   0: passed
   1: failed  input: 'def'  expected: 'abc'  actual: 'def'

Finished in 0.1 seconds
```
