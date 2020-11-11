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

para="para: $1"
echo $para
