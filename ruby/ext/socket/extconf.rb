require 'mkmf'

case RUBY_PLATFORM
when /bccwin32/
  test_func = "WSACleanup"
  have_library("ws2_32", "WSACleanup")
  have_func("closesocket")
when /mswin32|mingw/
  test_func = "WSACleanup"
  have_library("wsock32", "WSACleanup")
  have_func("closesocket")
when /cygwin/
  test_func = "socket"
when /beos/
  test_func = "socket"
  have_library("net", "socket")
  have_func("closesocket")
when /i386-os2_emx/
  test_func = "socket"
  have_library("socket", "socket")
else
  test_func = "socket"
  have_library("nsl", "t_open")
  have_library("socket", "socket")
end

$ipv6 = false
default_ipv6 = /cygwin/ !~ RUBY_PLATFORM
if enable_config("ipv6", default_ipv6)
  if try_link(<<EOF)
#include <sys/types.h>
#include <sys/socket.h>
main()
{
  socket(AF_INET6, SOCK_STREAM, 0);
}
EOF
    $CFLAGS+=" -DENABLE_IPV6"
    $ipv6 = true
  end
end

$ipv6type = nil
$ipv6lib = nil
$ipv6libdir = nil
$ipv6trylibc = nil
if $ipv6
  if macro_defined?("IPV6_INRIA_VERSION", <<EOF)
#include <netinet/in.h>
EOF
    $ipv6type = "inria"
    $CFLAGS="-DINET6 "+$CFLAGS
  elsif macro_defined?("__KAME__", <<EOF)
#include <netinet/in.h>
EOF
    $ipv6type = "kame"
    $ipv6lib="inet6"
    $ipv6libdir="/usr/local/v6/lib"
    $ipv6trylibc=true
    $CFLAGS="-DINET6 "+$CFLAGS
  elsif File.directory? "/usr/inet6"
    $ipv6type = "linux"
    $ipv6lib="inet6"
    $ipv6libdir="/usr/inet6/lib"
    $CFLAGS="-DINET6 -I/usr/inet6/include "+$CFLAGS
  elsif macro_defined?("_TOSHIBA_INET6", <<EOF)
#include <sys/param.h>
EOF
    $ipv6type = "toshiba"
    $ipv6lib="inet6"
    $ipv6libdir="/usr/local/v6/lib"
    $CFLAGS="-DINET6 "+$CFLAGS
  elsif macro_defined?("__V6D__", <<EOF)
#include </usr/local/v6/include/sys/v6config.h>
EOF
    $ipv6type = "v6d"
    $ipv6lib="v6"
    $ipv6libdir="/usr/local/v6/lib"
    $CFLAGS="-DINET6 -I/usr/local/v6/include "+$CFLAGS
  elsif macro_defined?("_ZETA_MINAMI_INET6", <<EOF)
#include <sys/param.h>
EOF
    $ipv6type = "zeta"
    $ipv6lib="inet6"
    $ipv6libdir="/usr/local/v6/lib"
    $CFLAGS="-DINET6 "+$CFLAGS
  else
    $ipv6lib=with_config("ipv6-lib", nil)
    $ipv6libdir=with_config("ipv6-libdir", nil)
    $CFLAGS="-DINET6 "+$CFLAGS
  end
  
  if $ipv6lib
    if File.directory? $ipv6libdir and File.exist? "#{$ipv6libdir}/lib#{$ipv6lib}.a"
      $LOCAL_LIBS = " -L#$ipv6libdir -l#$ipv6lib"
    elsif !$ipv6trylibc
      print <<EOS

Fatal: no #$ipv6lib library found.  cannot continue.
You need to fetch lib#{$ipv6lib}.a from appropriate
ipv6 kit and compile beforehand.
EOS
      exit
    end
  end
end

  if try_link(<<EOF)
#ifdef _WIN32
# include <windows.h>
# include <winsock.h>
#else
# include <sys/types.h>
# include <netdb.h>
# include <string.h>
# include <sys/socket.h>
# include <netinet/in.h>
#endif
int
main()
{
   struct sockaddr_in sin;

   sin.sin_len;
   return 0;
}
EOF
    $CFLAGS="-DHAVE_SIN_LEN "+$CFLAGS
end

  if try_link(<<EOF)
#ifdef _WIN32
# include <windows.h>
# include <winsock.h>
#else
# include <sys/types.h>
# include <netdb.h>
# include <string.h>
# include <sys/socket.h>
#endif
int
main()
{
   struct sockaddr_storage ss;

   ss.ss_family;
   return 0;
}
EOF
    $CFLAGS="-DHAVE_SOCKADDR_STORAGE "+$CFLAGS
else      #   doug's fix, NOW add -Dss_family... only if required!
$CPPFLAGS += " -Dss_family=__ss_family -Dss_len=__ss_len"
  if try_link(<<EOF)
#ifdef _WIN32
# include <windows.h>
# include <winsock.h>
#else
# include <sys/types.h>
# include <netdb.h>
# include <string.h>
# include <sys/socket.h>
#endif
int
main()
{
   struct sockaddr_storage ss;

   ss.ss_family;
   return 0;
}
EOF
    $CFLAGS="-DHAVE_SOCKADDR_STORAGE "+$CFLAGS
end
end

  if try_link(<<EOF)
#include <sys/types.h>
#include <netdb.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
int
main()
{
   struct sockaddr sa;

   sa.sa_len;
   return 0;
}
EOF
    $CFLAGS="-DHAVE_SA_LEN "+$CFLAGS
end

have_header("netinet/tcp.h") if not /cygwin/ =~ RUBY_PLATFORM # for cygwin 1.1.5
have_header("netinet/udp.h")

if have_func("sendmsg") | have_func("recvmsg")
  have_struct_member('struct msghdr', 'msg_control', ['sys/types.h', 'sys/socket.h'])
  have_struct_member('struct msghdr', 'msg_accrights', ['sys/types.h', 'sys/socket.h'])
end

$getaddr_info_ok = false
if !enable_config("wide-getaddrinfo", false) and try_run(<<EOF)
#include <sys/types.h>
#include <netdb.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>

#ifndef AF_LOCAL
#define AF_LOCAL AF_UNIX
#endif

main()
{
  int passive, gaierr, inet4 = 0, inet6 = 0;
  struct addrinfo hints, *ai, *aitop;
  char straddr[INET6_ADDRSTRLEN], strport[16];

  for (passive = 0; passive <= 1; passive++) {
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_protocol = IPPROTO_TCP;
    hints.ai_flags = passive ? AI_PASSIVE : 0;
    hints.ai_socktype = SOCK_STREAM;
    if ((gaierr = getaddrinfo(NULL, "54321", &hints, &aitop)) != 0) {
      (void)gai_strerror(gaierr);
      goto bad;
    }
    for (ai = aitop; ai; ai = ai->ai_next) {
      if (ai->ai_family == AF_LOCAL) continue;
      if (ai->ai_addr == NULL ||
          ai->ai_addrlen == 0 ||
          getnameinfo(ai->ai_addr, ai->ai_addrlen,
                      straddr, sizeof(straddr), strport, sizeof(strport),
                      NI_NUMERICHOST|NI_NUMERICSERV) != 0) {
        goto bad;
      }
      if (strcmp(strport, "54321") != 0) {
        goto bad;
      }
      switch (ai->ai_family) {
      case AF_INET:
        if (passive) {
          if (strcmp(straddr, "0.0.0.0") != 0) {
            goto bad;
          }
        } else {
          if (strcmp(straddr, "127.0.0.1") != 0) {
            goto bad;
          }
        }
        inet4++;
        break;
      case AF_INET6:
        if (passive) {
          if (strcmp(straddr, "::") != 0) {
            goto bad;
          }
        } else {
          if (strcmp(straddr, "::1") != 0) {
            goto bad;
          }
        }
        inet6++;
        break;
      case AF_UNSPEC:
        goto bad;
        break;
      default:
        /* another family support? */
        break;
      }
    }
  }

  if (!(inet4 == 0 || inet4 == 2))
    goto bad;
  if (!(inet6 == 0 || inet6 == 2))
    goto bad;

  if (aitop)
    freeaddrinfo(aitop);
  exit(0);

 bad:
  if (aitop)
    freeaddrinfo(aitop);
  exit(1);
}
EOF
  $getaddr_info_ok = true
end
if $ipv6 and not $getaddr_info_ok
      print <<EOS

Fatal: --enable-ipv6 is specified, and your OS seems to support IPv6 feature.
But your getaddrinfo() and getnameinfo() are appeared to be broken.  Sorry,
you cannot compile IPv6 socket classes with broken these functions.
You can try --enable-wide-getaddrinfo.
EOS
  exit
end
      
case with_config("lookup-order-hack", "UNSPEC")
when "INET"
  $CFLAGS="-DLOOKUP_ORDER_HACK_INET "+$CFLAGS
when "INET6"
  $CFLAGS="-DLOOKUP_ORDER_HACK_INET6 "+$CFLAGS
when "UNSPEC"
  # nothing special
else
  print <<EOS

Fatal: invalid value for --with-lookup-order-hack (expected INET, INET6 or UNSPEC)
EOS
  exit
end

$objs = ["socket.#{$OBJEXT}"]
    
if $getaddr_info_ok and have_func("getaddrinfo", "netdb.h") and have_func("getnameinfo", "netdb.h")
  have_getaddrinfo = true
else
  if try_link(<<EOF)
#ifndef _WIN32
#  include <sys/types.h>
#  include <netdb.h>
#  include <string.h>
#  include <sys/socket.h>
#  include <netinet/in.h>
#else
#  include <windows.h>
#  ifdef _WIN32_WCE
#    include <winsock.h>
#  else
#    include <winsock.h>
#  endif
#endif
int
main()
{
   struct in6_addr addr;
   unsigned char c;
   c = addr.s6_addr8;
   return 0;
}
EOF
    $CFLAGS="-DHAVE_ADDR8 "+$CFLAGS
  end
end

if have_getaddrinfo
  $CFLAGS="-DHAVE_GETADDRINFO "+$CFLAGS
else
  $CFLAGS="-I. "+$CFLAGS
  $objs += ["getaddrinfo.#{$OBJEXT}"]
  $objs += ["getnameinfo.#{$OBJEXT}"]
  have_func("inet_ntop") or have_func("inet_ntoa")
  have_func("inet_pton") or have_func("inet_aton")
  have_func("getservbyport")
  have_header("arpa/inet.h")
  have_header("arpa/nameser.h")
  have_header("resolv.h")
end

if !try_link(<<EOF)
#include <sys/types.h>
#include <netdb.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
int
main()
{
   socklen_t len;
   return 0;
}
EOF
  $CFLAGS="-Dsocklen_t=int "+$CFLAGS
end

have_header("sys/un.h")
have_header("sys/uio.h")

if have_func(test_func)
  have_func("hsterror")
  have_func("getipnodebyname") or have_func("gethostbyname2")
  unless have_func("gethostname")
    have_func("uname")
  end
  if enable_config("socks", ENV["SOCKS_SERVER"])
    if have_library("socks5", "SOCKSinit")
      $CFLAGS+=" -DSOCKS5 -DSOCKS"
    elsif have_library("socks", "Rconnect")
      $CFLAGS+=" -DSOCKS"
    end
  end
  create_makefile("socket")
end
