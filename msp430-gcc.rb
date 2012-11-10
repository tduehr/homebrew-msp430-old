require 'formula'

class Msp430Gcc < Formula
  homepage 'http://mspgcc.sourceforge.net/'
  url 'http://ftpmirror.gnu.org/gcc/gcc-4.6.3/gcc-4.6.3.tar.bz2'
  version '20120406'
  sha256  'e8f5853d4eec2f5ebaf8a72ae4d53c436aacf98153b2499f8635b48c4718a093'
  head 'git://mspgcc.git.sourceforge.net/gitroot/mspgcc/gcc'

  depends_on 'tduehr/msp430/msp430mcu'
  depends_on 'tduehr/msp430/msp430-binutils'
  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'libmpc'

  devel do
    version '20120911'
    url 'http://ftpmirror.gnu.org/gcc/gcc-4.7.0/gcc-4.7.0.tar.bz2'
    sha256 'a680083e016f656dab7acd45b9729912e70e71bbffcbf0e3e8aa1cccf19dc9a5'
  end

  option 'disable-cxx', 'Don\'t build the g++ compiler'

  def patches
    if build.devel?
      { :p1 => 'http://sourceforge.net/projects/mspgcc/files/Patches/gcc-4.7.0/msp430-gcc-4.7.0-20120911.patch' }
    elsif !build.head?
      {:p1 => [
          'http://sourceforge.net/projects/mspgcc/files/Patches/gcc-4.6.3/msp430-gcc-4.6.3-20120406.patch',
          'http://sourceforge.net/projects/mspgcc/files/Patches/LTS/20120406/msp430-gcc-4.6.3-20120406-sf3540953.patch',
          'http://sourceforge.net/projects/mspgcc/files/Patches/LTS/20120406/msp430-gcc-4.6.3-20120406-sf3559978.patch'
        ]
      }
    end
  end

  def install
    gmp = Formula.factory 'gmp'
    mpfr = Formula.factory 'mpfr'
    libmpc = Formula.factory 'libmpc'
    ENV.no_optimization

    args = [
            "--target=msp430",
            # Sandbox everything...
            "--prefix=#{prefix}",
            "--with-gmp=#{gmp.prefix}",
            "--with-mpfr=#{mpfr.prefix}",
            "--with-mpc=#{libmpc.prefix}",
            # ...except the stuff in share...
            "--datarootdir=#{share}",
            # ...and the binaries...
            "--bindir=#{bin}",
            # This shouldn't be necessary
            "--with-as=/usr/local/bin/msp430-as"
           ]

    # The C compiler is always built, C++ can be disabled
    languages = %w[c]
    languages << 'c++' unless build.include? 'disable-cxx'

    mkdir 'build'
    cd 'build' do
      system '../configure', "--enable-languages=#{languages.join(',')}", *args
      system 'make'

      # At this point `make check` could be invoked to run the testsuite. The
      # deja-gnu and autogen formulae must be installed in order to do this.

      system 'make install'

      multios = `gcc --print-multi-os-dir`.chomp

      # binutils already has a libiberty.a. We remove ours, because
      # otherwise, the symlinking of the keg fails
      ohai "checking...#{HOMEBREW_PREFIX + 'lib' + multios + 'libiberty.a'}"
      File.unlink "#{lib}/#{multios}/libiberty.a" if File.exist? HOMEBREW_PREFIX + 'lib' + multios + 'libiberty.a'

      # copy include and lib files from msp430mcu to where msp430-gcc searches for them
      # this wouldn't be necessary with a standard prefix
      msp430 = prefix + 'msp430'
      msp430mcu = Formula.factory('tduehr/msp430/msp430mcu')
      msp430_binutils = Formula.factory('tduehr/msp430/msp430-binutils')
      ohai "copying #{msp430mcu.prefix+'msp430'} -> #{prefix}"
      cp_r msp430mcu.prefix+"msp430", prefix
      ohai "copying #{msp430_binutils.prefix+'msp430'} -> #{prefix}"
      cp_r msp430_binutils.prefix+"msp430", prefix

      # don't install gpl man page if it already exists
      File.unlink man7 + 'gpl.7'

    end
  end
end
