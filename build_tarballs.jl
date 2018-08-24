# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "OsiBuilder"
version = v"0.107.9"

# Collection of sources required to build OsiBuilder
sources = [
    "https://github.com/coin-or/Osi/archive/releases/0.107.9.tar.gz" =>
    "e2c8a0ee4a2a0abe7475d67f7f98230e8bfbbcb6e74487877e757c996bfd6d30",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd Osi-releases-0.107.9/
update_configure_scripts
mkdir build
cd build/
export LDFLAGS="-L${prefix}/lib -lcoinglpk"
../configure --prefix=$prefix --with-pic --disable-pkg-config --with-blas="-L${prefix}/lib -lcoinblas -lgfortran" --host=${target} --enable-shared --enable-static --enable-dependency-linking lt_cv_deplibs_check_method=pass_all --with-glpk-lib="-L${prefix}/lib -lcoinglpk" --with-glpk-incdir="$prefix/include/coin/ThirdParty" --with-lapack="-L${prefix}/lib -lcoinlapack" --with-coinutils-lib="-L${prefix}/lib -lCoinUtils" --with-coinutils-incdir="$prefix/include/coin"
make -j${nproc}
make install

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:i686, :glibc),
    Linux(:x86_64, :glibc),
    Linux(:aarch64, :glibc),
    Linux(:armv7l, :glibc, :eabihf),
    Linux(:powerpc64le, :glibc),
    Linux(:i686, :musl),
    Linux(:x86_64, :musl),
    Linux(:aarch64, :musl),
    Linux(:armv7l, :musl, :eabihf),
    MacOS(:x86_64),
    Windows(:i686),
    Windows(:x86_64)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libOsiGlpk", :libOsiGlpk),
    LibraryProduct(prefix, "libOsi", :libOsi),
    LibraryProduct(prefix, "libOsiCommonTests", :libOsiCommonTests)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/juan-pablo-vielma/COINGLPKBuilder/releases/download/v1.10.5-beta4/build_COINGLPKBuilder.v1.10.5.jl",
    "https://github.com/juan-pablo-vielma/CoinUtilsBuilder/releases/download/v2.10.14-beta/build_CoinUtilsBuilder.v2.10.14.jl",
    "https://github.com/juan-pablo-vielma/COINBLASBuilder/releases/download/v1.4.6-beta2/build_COINBLASBuilder.v1.4.6.jl",
    "https://github.com/juan-pablo-vielma/COINLapackBuilder/releases/download/v1.5.6-beta/build_COINLapackBuilder.v1.5.6.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

