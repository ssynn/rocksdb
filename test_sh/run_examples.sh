# /bin/sh

# 测试一下最基本的随机写，顺序读，顺序写

bench_db_path="/tmp/rocksdb_run_examples_sh"
value_size="1024"
bench_compression="none"
histogram="true"
benchmarks="fillrandom,stats,readseq,readrandom,stats"
num="20000"
read_num="10000"

const_params="
    --db=$bench_db_path \
    --value_size=$value_size \
    --benchmarks=$benchmarks \
    --num=$num \
    --reads=$read_num \
    --histogram=$histogram
"

bench_file_path="$(dirname $PWD)/build/db_bench"

if [ ! -f "${bench_file_path}" ];then
bench_file_path="$(dirname $PWD)/db_bench"
fi

if [ ! -f "${bench_file_path}" ];then
bench_file_path="$PWD/db_bench"
fi

if [ ! -f "${bench_file_path}" ];then
echo "Error:${bench_file_path} or $(dirname $PWD )/build/db_bench not found!"
exit 1
fi

cmd="$bench_file_path $const_params "

if [ -n "$1" ];then
cmd="nohup $bench_file_path $const_params "
fi

cmd=${cmd}">run_examples.out"
echo $cmd 
eval $cmd

