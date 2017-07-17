---
layout: post
---

[ARC 078](http://arc078.contest.atcoder.jp/) に参加した。3問目が解けなかったので264位。レーティングは2440->2397。

### [C: Splitting Pile](http://arc078.contest.atcoder.jp/tasks/arc078_a)

上から i 枚とったときの和 を S\_i とすると、答えは \|S_i - (S_N - S_i)\| (i = 1, 2, ..., N-1) の最小値になる。

{% highlight rust %}
fn main() {
    let _: i32 = readln();
    let a: Vec<i64> = readln();
    let s: i64 = a.iter().sum();
    let mut t: i64 = 0;
    let mut answer = i64::max_value();
    for (i, &x) in a.iter().enumerate() {
        t += x;
        if i+1 != a.len() {
            answer = min(answer, (t - (s - t)).abs());
        }
    }
    println!("{}", answer);;
}
{% endhighlight %}
([submission](http://arc078.contest.atcoder.jp/submissions/1435124))

### [D: Fennec VS. Snuke](http://arc078.contest.atcoder.jp/tasks/arc078_b)

頂点1を根とする根付き木を考えたとき、はじめにフェネックとすぬけくんが取るべき頂点は、頂点1から頂点Nのパス上の頂点である。
それらを取りきった後は、それぞれが得た頂点の部分木を取ることができるので、それらのサイズを計算して比較する。

{% highlight rust %}
fn dfs(u: usize, p: usize, depth: &mut Vec<usize>, parent: &mut Vec<usize>, next: &Vec<Vec<usize>>) {
    for &v in &next[u] {
        if v != p {
            depth[v] = depth[u] + 1;
            parent[v] = u;
            dfs(v, u, depth, parent, next);
        }
    }
}
fn cnt(u: usize, p: usize, next: &Vec<Vec<usize>>) -> usize {
    next[u].iter().filter(|&v| *v != p).map(|&v| cnt(v, u, next)).sum::<usize>() + 1
}
fn main() {
    let n: usize = readln();
    let ps: Vec<(usize, usize)> = readlns(n-1);
    let mut next: Vec<Vec<usize>> = vec![vec![]; n];
    for (a, b) in ps {
        next[a-1].push(b-1);
        next[b-1].push(a-1);
    }
    let mut parent: Vec<usize> = vec![0; n];
    let mut depth: Vec<usize> = vec![0; n];
    parent[0] = 0;
    depth[0] = 0;
    dfs(0, 0, &mut depth, &mut parent, &next);
    let c = (depth[n-1] - 1) / 2;
    let mut root = n-1;
    for i in 0..c {
        root = parent[root];
    }
    let b = cnt(root, parent[root], &next);
    let a = n - b;
    println!("{}", if a <= b { "Snuke" } else { "Fennec" });
}
{% endhighlight %}
([submission](http://arc078.contest.atcoder.jp/submissions/1435145))

### [E: Awkward Response](http://arc078.contest.atcoder.jp/tasks/arc078_c)

位の大きい桁から順番に数字を確定していく。すでに確定している数字列を s としたとき、次の桁の数字 c ('0' <= c <= '9') は s+c が Y となる最小の c である。
ただし最後の桁を決定するときは、つねに Y となるので、s + '9' が Y になるときは、例外的に処理する。また、このとき 10...0 や 99...9 に気をつける。

{% highlight rust %}
use std::io;
use std::io::prelude::*;

fn ask(n: String) -> bool {
    let mut stdout = io::stdout();
    stdout.write(format!("? {}\n", n).as_bytes());
    stdout.flush();
    let mut stdin = io::stdin();
    let mut input = String::new();
    stdin.read_line(&mut input);
    input.starts_with("Y")
}
fn is_last(s: &str) -> bool {
    if s.starts_with("1") || (s.len() == 0 && ask("1000000000000".to_string())) {
        let mut t = String::new();
        for _ in 0..s.len()+1 {
            t.push('9');
        }
        ask(t)
    } else {
        let mut t = String::new();
        t.push('1');
        for _ in 0..s.len()+1 {
            t.push('0');
        }
        !ask(t)
    }
}
fn find_last(s: &str) -> i32 {
    let mut lb = if s.len() == 0 { 1 } else { 0 } - 1;
    let mut ub = 9;
    while ub - lb > 1 {
        let x = (lb + ub) / 2;
        if ask(s.to_string() + &x.to_string() + "0") {
            ub = x;
        } else {
            lb = x;
        }
    }
    ub
}
fn find_char(s: &str) -> (i32, bool) {
    let mut lb = 0;
    let mut ub = 10;
    while ub - lb > 1 {
        let x = (lb + ub) / 2;
        if ask(s.to_string() + &x.to_string()) {
            lb = x;
        } else {
            ub = x;
        }
    }
    if lb != 9 {
        (lb, false)
    } else if is_last(s) {
        (find_last(s), true)
    } else {
        (9, false)
    }
}
fn main() {
    let mut ans = String::new();
    loop {
        let (a, b) = find_char(&ans);
        ans += &a.to_string();
        if b {
            break;
        }
    }

    let mut stdout = io::stdout();
    stdout.write(format!("! {}\n", ans).as_bytes());
    stdout.flush();
}
{% endhighlight %}
([submission](http://arc078.contest.atcoder.jp/submissions/1430642))
