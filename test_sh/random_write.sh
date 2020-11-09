db="/tmp/rocksdb_random_write"

value_size="4096"
compression_type="none"
histogram="true"
benchmarks="fillrandomwithmoniter,stats"

report_ops_latency="true"

num="200000"

const_params=""

function FILL_PARAMS(){
    if [ -n "$db" ];then
        const_params=$const_params"--db=$bench_db_path "
    fi

    if [ -n "$value_size" ];then
        const_params=$const_params"--value_size=$value_size "
    fi

    if [ -n "$compression_type" ];then
        const_params=$const_params"--compression_type=$compression_type "
    fi

    if [ -n "$histogram" ];then
        const_params=$const_params"--histogram=$histogram "
    fi

    if [ -n "$benchmarks" ];then
        const_params=$const_params"--benchmarks=$benchmarks "
    fi

    if [ -n "$report_ops_latency" ];then
        const_params=$const_params"--report_ops_latency=$report_ops_latency "
    fi

    if [ -n "$num" ];then
        const_params=$const_params"--num=$num "
    fi
}

FILL_PARAMS

# 把输出的一堆乱七八糟的文件拷贝到result文件夹
COPY_OUT_FILE(){
    mkdir $bench_file_dir/result > /dev/null 2>&1
    res_dir=$bench_file_dir/result/value-$value_size
    mkdir $res_dir > /dev/null 2>&1
    \mv -f $bench_file_dir/compaction.csv $res_dir/
    \mv -f $bench_file_dir/OP_DATA $res_dir/
    \mv -f $bench_file_dir/OP_TIME.csv $res_dir/
    \mv -f $bench_file_dir/out.out $res_dir/
    \mv -f $bench_file_dir/Latency.csv $res_dir/
    \mv -f $bench_file_dir/PerSecondLatency.csv $res_dir/
    \mv -f $db/OPTIONS-* $res_dir/
    #\cp -f $db/LOG $res_dir/
}

bench_file_path="$(dirname $PWD)/db_bench"

if [ ! -f "$bench_file_path" ];then
    bench_file_path="$(dirname $PWD)/build/db_bench"
fi

if [ ! -f "$bench_file_path" ];then
    bench_file_path="$PWD/db_bench"
fi


bench_file_dir="$PWD"

cmd="$bench_file_path $const_params"
cmd=$cmd">fillrandomwithmoniter.out"

echo $cmd
eval $cmd

COPY_OUT_FILE





