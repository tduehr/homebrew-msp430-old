require 'formula'

class Msp430Gdb < Formula
  homepage 'http://mspgcc.sourceforge.net/'
  url 'http://ftpmirror.gnu.org/gdb/gdb-7.2a.tar.bz2'
  version '20111205'
  sha256  '3c24dde332e33bfe2d5980c726d76224ebf8304278112a07bf701f8d2145d9bc'
  head 'git://mspgcc.git.sourceforge.net/gitroot/mspgcc/gdb'

  depends_on 'tduehr/msp430/msp430mcu'
  depends_on 'tduehr/msp430/msp430-gcc'

  # --enable-build-with-cxx build with C++ compiler instead of C compiler
  option 'enable-build-with-cxx', 'build with C++ compiler instead of C compiler [untested]'

  def patches
    if !build.head?
      {:p1 => 'http://sourceforge.net/projects/mspgcc/files/Patches/gdb-7.2a/msp430-gdb-7.2a-20111205.patch'}
    end
  end

  def install
    gmp = Formula.factory 'gmp'
    mpfr = Formula.factory 'mpfr'
    libmpc = Formula.factory 'libmpc'

    args = [
            "--target=msp430",
            # Sandbox everything...
            "--prefix=#{prefix}",
            "--with-gmp=#{gmp.prefix}",
            "--with-mpfr=#{mpfr.prefix}",
            "--with-mpc=#{libmpc.prefix}",
            # ...except the stuff in share...
            # "--datarootdir=#{share}",
            # ...and the binaries...
            # "--bindir=#{bin}",
            # This shouldn't be necessary
            # "--with-as=/usr/local/bin/msp430-as"
           ]

    args << '--enable-build-with-cxx' if build.include? 'enable-build-with-cxx'

    mkdir 'build'
    cd 'build' do
      system '../configure', *args
      system 'make'

      system 'make install'

      multios = `gcc --print-multi-os-dir`.chomp

      # binutils already has a libiberty.a. We remove ours, because
      # otherwise, the symlinking of the keg fails
      ohai "checking...", HOMEBREW_PREFIX + 'lib' + multios + 'libiberty.a'
      File.unlink "#{lib}/#{multios}/libiberty.a" if File.exist? HOMEBREW_PREFIX + 'lib' + multios + 'libiberty.a'
    end
  end
end
