require 'formula'

class Msp430mcu < Formula
  homepage 'http://mspgcc.sourceforge.net/'
  url 'http://sourceforge.net/projects/mspgcc/files/msp430mcu/msp430mcu-20120406.tar.bz2'
  sha256  '0637014e8e509746c3f6df8e1d65b786770d162b3a0b86548bdf76ac3102c96e'
  head 'git://mspgcc.git.sourceforge.net/gitroot/mspgcc/msp430mcu'

  keg_only "cross compile tools"

  devel do
    url 'http://sourceforge.net/projects/mspgcc/files/msp430mcu-devel/msp430mcu-devel-20120406.tar.bz2'
    version '20120716'
    sha256  '3588d993462f4f062b6c3fe919900fcd22a4f2ce4d6496b5477f29f8a6ab821d'
  end

  def patches
    unless (build.devel? || build.head?)
      { :p1 => 'http://sourceforge.net/projects/mspgcc/files/Patches/LTS/20120406/msp430mcu-20120406-sf3522088.patch/download'}
    end
  end

  def install
    mkdir prefix + 'bin'
    ENV.append 'MSP430MCU_ROOT', Dir.pwd
    system "scripts/install.sh", prefix
  end
end
