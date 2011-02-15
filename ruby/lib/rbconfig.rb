
# This file was created by mkconfig.rb when ruby was built.  Any
# changes made to this file will be lost the next time ruby is built.

module Config
  RUBY_VERSION == "1.8.2" or
    raise "ruby lib version (1.8.2) doesn't match executable version (#{RUBY_VERSION})"

#  TOPDIR = File.dirname(__FILE__).sub!(%r'/lib/ruby/1\.8/i386\-linux\Z', '')
  TOPDIR = "/ruby_root"
  DESTDIR = '' unless defined? DESTDIR
  CONFIG = {}
  CONFIG["DESTDIR"] = DESTDIR
  CONFIG["srcdir"] = "/home/ben/src/ruby1.8-1.8.1+1.8.2pre3/build-tree/ruby-1.8.2"
  CONFIG["prefix"] = (TOPDIR || DESTDIR + "/usr")
  CONFIG["ruby_install_name"] = "ruby"
  CONFIG["EXEEXT"] = ".exe"
  CONFIG["SHELL"] = "/bin/bash"
  CONFIG["PATH_SEPARATOR"] = ":"
  CONFIG["PACKAGE_NAME"] = ""
  CONFIG["PACKAGE_TARNAME"] = ""
  CONFIG["PACKAGE_VERSION"] = ""
  CONFIG["PACKAGE_STRING"] = ""
  CONFIG["PACKAGE_BUGREPORT"] = ""
  CONFIG["exec_prefix"] = "$(prefix)"
  CONFIG["bindir"] = "$(exec_prefix)/bin"
  CONFIG["sbindir"] = "$(exec_prefix)/sbin"
  CONFIG["libexecdir"] = "$(exec_prefix)/libexec"
  CONFIG["datadir"] = "$(prefix)/share"
  CONFIG["sysconfdir"] = "$(DESTDIR)/etc"
  CONFIG["sharedstatedir"] = "$(prefix)/com"
  CONFIG["localstatedir"] = "$(DESTDIR)/var"
  CONFIG["libdir"] = "$(exec_prefix)/lib"
  CONFIG["includedir"] = "$(prefix)/include"
  CONFIG["oldincludedir"] = "/usr/include"
  CONFIG["infodir"] = "$(prefix)/info"
  CONFIG["mandir"] = "$(datadir)/man"
  CONFIG["build_alias"] = ""
  CONFIG["host_alias"] = ""
  CONFIG["target_alias"] = "i386-linux"
  CONFIG["ECHO_C"] = ""
  CONFIG["ECHO_N"] = "-n"
  CONFIG["ECHO_T"] = ""
  CONFIG["LIBS"] = "-lpthread -ldl -lcrypt -lm "
  CONFIG["MAJOR"] = "1"
  CONFIG["MINOR"] = "8"
  CONFIG["TEENY"] = "2"
  CONFIG["build"] = "i686-pc-linux-gnu"
  CONFIG["build_cpu"] = "i686"
  CONFIG["build_vendor"] = "pc"
  CONFIG["build_os"] = "linux-gnu"
  CONFIG["host"] = "i686-pc-linux-gnu"
  CONFIG["host_cpu"] = "i686"
  CONFIG["host_vendor"] = "pc"
  CONFIG["host_os"] = "linux-gnu"
  CONFIG["target"] = "i386-pc-linux"
  CONFIG["target_cpu"] = "i386"
  CONFIG["target_vendor"] = "pc"
  CONFIG["target_os"] = "linux"
  CONFIG["CC"] = "gcc"
  CONFIG["ac_ct_CC"] = "gcc"
  CONFIG["CFLAGS"] = "-Wall -g -O2  -fPIC"
  CONFIG["LDFLAGS"] = " -rdynamic"
  CONFIG["CPPFLAGS"] = ""
  CONFIG["OBJEXT"] = "o"
  CONFIG["CPP"] = "gcc -E"
  CONFIG["EGREP"] = "grep -E"
  CONFIG["GNU_LD"] = "yes"
  CONFIG["CPPOUTFILE"] = "-o conftest.i"
  CONFIG["OUTFLAG"] = "-o "
  CONFIG["YACC"] = "bison -y"
  CONFIG["RANLIB"] = "ranlib"
  CONFIG["ac_ct_RANLIB"] = "ranlib"
  CONFIG["AR"] = "ar"
  CONFIG["ac_ct_AR"] = "ar"
  CONFIG["NM"] = ""
  CONFIG["ac_ct_NM"] = ""
  CONFIG["WINDRES"] = ""
  CONFIG["ac_ct_WINDRES"] = ""
  CONFIG["DLLWRAP"] = ""
  CONFIG["ac_ct_DLLWRAP"] = ""
  CONFIG["LN_S"] = "ln -s"
  CONFIG["SET_MAKE"] = ""
  CONFIG["LIBOBJS"] = ""
  CONFIG["ALLOCA"] = ""
  CONFIG["DLDFLAGS"] = ""
  CONFIG["ARCH_FLAG"] = ""
  CONFIG["STATIC"] = ""
  CONFIG["CCDLFLAGS"] = " -fPIC"
  CONFIG["LDSHARED"] = "gcc -shared"
  CONFIG["DLEXT"] = "so"
  CONFIG["DLEXT2"] = ""
  CONFIG["LIBEXT"] = "a"
  CONFIG["LINK_SO"] = ""
  CONFIG["LIBPATHFLAG"] = " -L\"%s\""
  CONFIG["RPATHFLAG"] = ""
  CONFIG["TRY_LINK"] = ""
  CONFIG["STRIP"] = "strip -S -x"
  CONFIG["EXTSTATIC"] = ""
  CONFIG["setup"] = "Setup"
  CONFIG["MINIRUBY"] = "./miniruby$(EXEEXT)"
  CONFIG["PREP"] = ""
  CONFIG["ARCHFILE"] = ""
  CONFIG["RDOCTARGET"] = ""
  CONFIG["XCFLAGS"] = ""
  CONFIG["XLDFLAGS"] = " -L."
  CONFIG["LIBRUBY_LDSHARED"] = "gcc -shared"
  CONFIG["LIBRUBY_DLDFLAGS"] = "-Wl,-soname,lib$(RUBY_SO_NAME).so.$(MAJOR).$(MINOR)"
  CONFIG["RUBY_INSTALL_NAME"] = "ruby"
  CONFIG["rubyw_install_name"] = ""
  CONFIG["RUBYW_INSTALL_NAME"] = ""
  CONFIG["RUBY_SO_NAME"] = "$(RUBY_INSTALL_NAME)"
  CONFIG["LIBRUBY_A"] = "lib$(RUBY_SO_NAME)-static.a"
  CONFIG["LIBRUBY_SO"] = "lib$(RUBY_SO_NAME).so.$(MAJOR).$(MINOR).$(TEENY)"
  CONFIG["LIBRUBY_ALIASES"] = "lib$(RUBY_SO_NAME).so.$(MAJOR).$(MINOR) lib$(RUBY_SO_NAME).so"
  CONFIG["LIBRUBY"] = "$(LIBRUBY_SO)"
  CONFIG["LIBRUBYARG"] = "$(LIBRUBYARG_SHARED)"
  CONFIG["LIBRUBYARG_STATIC"] = "-l$(RUBY_SO_NAME)-static"
  CONFIG["LIBRUBYARG_SHARED"] = "-l$(RUBY_SO_NAME)"
  CONFIG["SOLIBS"] = "$(LIBS)"
  CONFIG["DLDLIBS"] = " -lc"
  CONFIG["ENABLE_SHARED"] = "yes"
  CONFIG["MAINLIBS"] = ""
  CONFIG["COMMON_LIBS"] = ""
  CONFIG["COMMON_MACROS"] = ""
  CONFIG["COMMON_HEADERS"] = ""
  CONFIG["EXPORT_PREFIX"] = ""
  CONFIG["MAKEFILES"] = "Makefile"
  CONFIG["arch"] = "i386-linux"
  CONFIG["sitearch"] = "i386-linux"
  CONFIG["sitedir"] = "$(prefix)/local/lib/site_ruby"
  CONFIG["configure_args"] = "'--enable-frame-address' '--target=i386-linux' '--program-suffix=1.8' '--prefix=/usr' '--datadir=$(prefix)/share' '--mandir=$(datadir)/man' '--sysconfdir=/etc' '--localstatedir=/var' '--with-sitedir=$(prefix)/local/lib/site_ruby' '--with-default-kcode=none' '--with-dbm-type=gdbm_compat' '--with-tklib=tk8.4' '--with-tcllib=tcl8.4' '--with-tcl-include=/usr/include/tcl8.4' '--with-bundled-sha1' '--with-bundled-md5' '--with-bundled-rmd160' '--enable-pthread' '--enable-shared' '--enable-ipv6' '--with-lookup-order-hack=INET' 'CFLAGS=-Wall -g -O2' 'target_alias=i386-linux'"
  CONFIG["NROFF"] = "/usr/bin/nroff"
  CONFIG["MANTYPE"] = "doc"
  CONFIG["LTLIBOBJS"] = ""
  CONFIG["abs_srcdir"] = "$(ac_abs_srcdir)"
  CONFIG["abs_top_srcdir"] = "$(ac_abs_top_srcdir)"
  CONFIG["builddir"] = "$(ac_builddir)"
  CONFIG["abs_builddir"] = "$(ac_abs_builddir)"
  CONFIG["top_builddir"] = "$(ac_top_builddir)"
  CONFIG["abs_top_builddir"] = "$(ac_abs_top_builddir)"
  CONFIG["ruby_version"] = "$(MAJOR).$(MINOR)"
  CONFIG["rubylibdir"] = "$(libdir)/ruby/$(ruby_version)"
  CONFIG["archdir"] = "$(rubylibdir)/$(arch)"
  CONFIG["sitelibdir"] = "$(sitedir)/$(ruby_version)"
  CONFIG["sitearchdir"] = "$(sitelibdir)/$(sitearch)"
  CONFIG["compile_dir"] = "/home/ben/src/ruby1.8-1.8.1+1.8.2pre3/build-tree/ruby-1.8.2"
  MAKEFILE_CONFIG = {}
  CONFIG.each{|k,v| MAKEFILE_CONFIG[k] = v.dup}
  def Config::expand(val, config = CONFIG)
    val.gsub!(/\$\$|\$\(([^()]+)\)|\$\{([^{}]+)\}/) do |var|
      if !(v = $1 || $2)
	'$'
      elsif key = config[v]
	config[v] = false
        Config::expand(key, config)
	config[v] = key
      else
	var
      end
    end
    val
  end
  CONFIG.each_value do |val|
    Config::expand(val)
  end
end
CROSS_COMPILING = nil unless defined? CROSS_COMPILING
