---
layout: post
title: Rust の Web アプリケーション を Heroku で動かす
---

この記事では、Rust で書かれた Web アプリケーションを Heroku で簡単にデプロイする方法について説明します。

記事の内容は、ほぼ [Deploying Rust applications to Heroku, with example code for Iron \| Random Hacks](http://www.randomhacks.net/2014/09/17/deploying-rust-heroku-iron/) と同じです。正確な情報が読みたい人は原文を読んで下さい。

サンプルレポジトリを使う
-------------

とりあえずデプロイしたいときは [サンプルのレポジトリ](https://github.com/emk/heroku-rust-cargo-hello) を利用してください。以下のコマンドでデプロイすることができます。
```
$ git clone https://github.com/emk/heroku-rust-cargo-hello.git
$ cd heroku-rust-cargo-hello
$ heroku create --buildpack https://github.com/emk/heroku-buildpack-rust.git
$ git push heroku master
```

はじめから作る方法
-------------

以下では、サンプルレポジトリを使わない方法を説明します。
今回はディレクトリの名前を`hello-heroku`とします。以下のコマンドで初期状態のディレクトリが作られます。
```
$ cargo new --bin hello-heroku
```

依存ライブラリを `Cargo.toml` に追加します。
```
[dependencies]
iron = "*"
router = "*"
```

`src/main.rs` を編集します。ここでは `/name` にアクセスすると "Hello, name!" が 返されるような Web サーバーを記述します。
詳細は [iron](https://github.com/iron/iron) や [router](https://github.com/iron/router) の example や document を読んで下さい。

```rust
extern crate iron;
extern crate router;

use std::env;
use iron::prelude::*;
use iron::status;
use router::Router;

fn get_server_port() -> u16 {
    env::var("PORT").ok()
        .and_then(|p| p.parse().ok())
        .unwrap_or(8080)
}

fn handler(req: &mut Request) -> IronResult<Response> {
    let params = req.extensions.get::<Router>().unwrap();
    let name = params.find("name").unwrap_or("world");
    Ok(Response::with((status::Ok, format!("Hello, {}!", name))))
}

fn main() {
    let mut router = Router::new();
    router.get("/", handler, "index");
    router.get("/:name", handler, "name");

    Iron::new(router).http(("0.0.0.0", get_server_port())).unwrap();
}
```


ビルドして手元で動くかどうか確かめます。
```
$ cargo build
$ ./target/debug/hello-heroku
$ curl http://localhost:8080/heroku
```
`Hello, heroku!`が表示されれば成功です。

次に、Herokuにデプロイするための設定を行います。
```
$ heroku create --buildpack https://github.com/emk/heroku-buildpack-rust.git
```
`Procfile` に以下の内容を書いて保存します。
```
web: ./target/release/hello-heroku
```

最後に、`git push`をします。
```
$ git add . && git commit -m “Initial commit”
$ git push heroku master
```

```
remote: -----> Launching...
remote:        Released v3
remote:        https://hoge-fuga-12345.herokuapp.com/ deployed to Heroku
remote:
remote: Verifying deploy... done.
```
のように表示されたら、成功です。
