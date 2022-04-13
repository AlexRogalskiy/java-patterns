# HOWTO Guide

## Steps

To manage python project packages you can use - `pip-compile-multi` utility.

To pin packages to the current versions you should run the following command:

```shell
$ pip-compile-multi -n local -n testwin
```

It produces files `base.txt`, `test.txt`, `local.txt` and `testwin.txt` with recursively retrieved hard-pinned package
versions.

The second command takes these `.txt` files and produce `.hash` files with attached package hashes:

```shell
$ pip-compile-multi -n local -n testwin -g local -g testwin -i txt -o hash
```

To automate this tasks you can use `tox` utility with the following configuration:

```ini
[testenv:upgrade]
basepython = python3.9
deps = pip-compile-multi
commands =
    pip-compile-multi -n local -n testwin
    pip-compile-multi -n local -n testwin -g local -g testwin -i txt -o hash
```

To execute tox upgrade configuration you should run:

```shell
$ tox -e upgrade
```

## Links

[tox](https://tox.readthedocs.io/en/latest/)
[pip-compile-multi](https://pip-compile-multi.readthedocs.io/en/latest/)
