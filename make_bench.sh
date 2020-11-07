mkdir build
cd build

CMK="cmake"

if [ -f "/usr/bin/cmake3" ];then
    CMK="cmake3"
fi

cmd=${CMK}" .. -DWITH_SNAPPY=1 -DCMAKE_BUILD_TYPE=Release=release"

echo $cmd
eval $cmd
make -j