# /bin/sh



bench_db_path="/tmp/rocksdb_ycsbworkloada"
value_size="1024"
bench_compression="none"
histogram="true"
benchmarks="ycsbwklda,stats"
max_background_jobs="2"
max_bytes_for_level_base="`expr 256 \* 1024 \* 1024`"
benchmark_write_rate_limit="`expr 20000 \* \( $value_size + 16 \)`"  #20K iops, key: 16 bytes

report_ops_latency="true"
report_fillrandom_latency="true"

YCSB_uniform_distribution="true"
ycsb_workloada_num="10000"
num="20000"
threads="2"

const_params=""

function FILL_PARAMS(){
    if [ -n "$bench_db_path" ];then
        const_params=$const_params"--db=$bench_db_path "
    fi

    if [ -n "$value_size" ];then
        const_params=$const_params"--value_size=$value_size "
    fi

    if [ -n "$benchmarks" ];then
        const_params=$const_params"--benchmarks=$benchmarks "
    fi

    if [ -n "$histogram" ];then
        const_params=$const_params"--histogram=$histogram "
    fi

    if [ -n "$num" ];then
        const_params=$const_params"--num=$num "
    fi

    if [ -n "$max_background_jobs" ];then
        const_params=$const_params"--max_background_jobs=$max_background_jobs "
    fi

    if [ -n "$max_bytes_for_level_base" ];then
        const_params=$const_params"--max_bytes_for_level_base=$max_bytes_for_level_base "
    fi

    if [ -n "$threads" ];then
        const_params=$const_params"--threads=$threads "
    fi

    if [ -n "$report_ops_latency" ];then
        const_params=$const_params"--report_ops_latency=$report_ops_latency "
    fi

    if [ -n "$report_fillrandom_latency" ];then
        const_params=$const_params"--report_fillrandom_latency=$report_fillrandom_latency "
    fi

    if [ -n "$YCSB_uniform_distribution" ];then
        const_params=$const_params"--YCSB_uniform_distribution=$YCSB_uniform_distribution "
    fi

    if [ -n "$ycsb_workloada_num" ];then
        const_params=$const_params"--ycsb_workloada_num=$ycsb_workloada_num "
    fi
}

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



bench_file_path="$(dirname $PWD)/build/db_bench"
bench_file_dir="$PWD"

FILL_PARAMS


if [ ! -f "$bench_file_path" ];then
    bench_file_path="$(dirname $PWD)/db_bench"
fi

if [ ! -f "$bench_file_path" ];then
    bench_file_path="$PWD/db_bench"
fi


cmd="$bench_file_path $const_params"
cmd=$cmd">YCSBA.out"

echo $cmd
eval $cmd

COPY_OUT_FILE




