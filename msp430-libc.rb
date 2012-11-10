require 'formula'

class Msp430Libc < Formula
  homepage 'http://mspgcc.sourceforge.net/'
  url 'https://sourceforge.net/projects/mspgcc/files/msp430-libc/msp430-libc-20120224.tar.bz2'
  sha256  'b67a33881aa6b456c5c99dea5ea655892455fde1317d5bda818e9c6ee34a3f82'
  head 'git://mspgcc.git.sourceforge.net/gitroot/mspgcc/msp430-libc'

  devel do
    url 'http://sourceforge.net/projects/mspgcc/files/msp430-libc-devel/msp430-libc-devel-20120716.tar.bz2'
    sha256  'cbd78f468e9e3b2df9060f78e8edb1b7bfeb98a9abfa5410d23f63a5dc161c7d'
  end

  depends_on 'tduehr/msp430/msp430mcu'
  depends_on 'gettext' => :build
  depends_on 'tduehr/msp430/msp430-gcc' => :build
  
  option 'disable-printf-int64', 'Remove 64-bit integer support to printf formats'
  option 'disable-printf-int32', 'Remove 32-bit integer support from printf formats'
  option 'enable-ieee754-errors', 'Use IEEE 754 error checking in libfp functions'
  
  def patches
    unless (build.devel? || build.head?)
      { :p1 => 'http://sourceforge.net/projects/mspgcc/files/Patches/LTS/20120406/msp430-libc-20120224-sf3522752.patch/download'}
    end
  end
  
  def install
    msp430_gcc = Formula.factory('tduehr/msp430/msp430-gcc')
    args = []
    args << '--disable-printf-int64' if build.include? 'disable-printf-int64'
    args << '--disable-printf-int32' if build.include? 'disable-printf-int32'
    args << '--enable-ieee754-errors' if build.include? 'enable-ieee754-errors'

    system "./configure", "--prefix=#{prefix}", *args

    cd 'src' do
      mkdir_p 'Build/mcpu-430x/mmpy-16'
      mkdir_p 'Build/mmpy-16'
      system "make install"
      msp430 = File.join prefix, 'msp430'
      # copy include and lib files where msp430-gcc searches for them
      # this wouldn't be necessary with a standard prefix
      ohai "copying #{msp430} -> #{msp430_gcc.prefix}"
      cp_r msp430, msp430_gcc.prefix
    end
  end
end
