```shell
$ touch a
$ cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1000 | sort | uniq > test/a
$ touch b
$ yes a | head -n 524288 | tr -d '\n' > test/b
$ touch c
$ yes aabbcc | head -n 524288 | tr -d '\n' > test/c

$ zip -r test test
```
