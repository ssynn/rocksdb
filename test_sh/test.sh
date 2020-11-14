bench_file_path="$(dirname $PWD)/build/db_bench"
bench_file_path2="$PWD/db_bench"
dirname="$(dirname $PWD)"
limit="`expr 256 \* 1024 \* 1024`"

# cmd="ls -ll "

# echo $cmd >out.out
# eval $cmd
# echo $bench_file_path
# echo $bench_file_path2
# exit 1
# echo $dirname
# echo $PPID

# echo 234ff$limit

# if [ -n "out.out" ];then
#     rm out.out
# fi

# echo 3 > /proc/sys/vm/drop_caches

# para="para: $1"
# echo $para

# ycsb_workloada_num="10000"
# threads="2"
# let num=${threads}*${ycsb_workloada_num}
# echo $num


# workload="B"

# if [ $workload == "A" ];then
#     YCSB_write_ratio="50" # A:50, B:5 C:0 D:5
#     YCSB_distribution="1" # uniform=0 zipfian=1 latest=2
# fi

# if [ $workload == "B" ];then
#     YCSB_write_ratio="5" # A:50, B:5 C:0 D:5
#     YCSB_distribution="1" # uniform=0 zipfian=1 latest=2
# fi

# if [ $workload == "C" ];then
#     YCSB_write_ratio="0" # A:50, B:5 C:0 D:5
#     YCSB_distribution="1" # uniform=0 zipfian=1 latest=2
# fi

# if [ $workload == "D" ];then
#     YCSB_write_ratio="5" # A:50, B:5 C:0 D:5
#     YCSB_distribution="2" # uniform=0 zipfian=1 latest=2
# fi

# echo $YCSB_write_ratio
# echo $YCSB_distribution


ycsb_workloada_num="5000"
threads="2"
if [ ! "$num" ];then
    let num=${threads}*${ycsb_workloada_num}
    echo $num
fi

# let num=${threads}*${ycsb_workloada_num}


echo $num