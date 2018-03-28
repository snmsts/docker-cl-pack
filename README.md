# Common Lisp environment with docker

## prepare dev env.

I tested this on Ubuntu 17.10 where ``docker``,``make``,``tar`` command are available.

```
make base
```

would download debian linux then install roswell and emacs. docker image are named based on the directory of the checkouted directory.

```
make shell
```

would invoke /bin/sh with the container which are build from the process above.
but it doesn't have enough setup for emacs.

```
make install-emacs
```

would install emacs/slime/clhs and so on. same level as [docker-cl-devel2](https://github.com/eshamster/docker-cl-devel2)

you can develop lisp application there.

## prepare executable and docker image for deploy.

```
make app
```

would compile and build executable at ``home/app``


```
make pack
```

would copy app made by ``make app`` into alpine with glibc docker image.

## destroy

```
make clean
```

would destroy everything

## Thanks to

eshamster (hamgoostar@gmail.com)

## Author

SANO Masatoshi (snmsts@gmail.com)

## Copyright

Copyright (c) 2018 SANO Masatoshi (snmsts@gmail.com)

## License

Distributed under the MIT License
