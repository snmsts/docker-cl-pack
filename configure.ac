AC_INIT([niko3],[0.0.0])
AM_INIT_AUTOMAKE([foreign])
AC_CONFIG_FILES(Makefile Dockerfile)
AC_CONFIG_HEADERS()

AC_CHECK_PROG([ROSWELL], [ros], [yes])
AC_CHECK_PROG([DOCKER], [docker], [yes])

if test "x$ROSWELL" != xyes; then
  AC_MSG_ERROR([roswell required]);
fi

AC_OUTPUT
