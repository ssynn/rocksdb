

//
//  ycsbc.cc
//  YCSB-C
//
//  Created by Jinglei Ren on 12/19/14.
//  Copyright (c) 2014 Jinglei Ren <jinglei@ren.systems>.
//

#include <cstring>
#include <future>
#include <iostream>
#include <string>
#include <vector>

#include "rocksdb/db.h"
#include "utilities/ycsbcore/client.h"
#include "utilities/ycsbcore/core_workload.h"
#include "utilities/ycsbcore/timer.h"
#include "utilities/ycsbcore/utils.h"
// #include "db/db_factory.h"

using namespace std;

namespace ycsbc {

class RocksDB : public ycsbc::DB {
 public:
  RocksDB(utils::Properties prop) {
    option.create_if_missing = true;
    rocksdb::Status s = rocksdb::DB::Open(option, "/tmp/ycsbc_rocksdb_test", &this->db);
    assert(s.ok());
  }

  void Init() {}

  void Close() {}

  int Read(const std::string &table, const std::string &key,
           const std::vector<std::string> *fields, std::string &result) {
    rocksdb::Status s = this->db->Get(this->read_option, key, &result); 
    if (s.ok()) {
      return kOK;
    }
    else if (s.IsNotFound()) {
      return kErrorNoData;
    }
    return kErrorConflict;
  }

  int Scan(const std::string &table, const std::string &key, int record_count,
           const std::vector<std::string> *fields,
           std::vector<std::string> &result) {
    rocksdb::Iterator *iter = db->NewIterator(read_option);
    int i = 0;
    for (iter->Seek(key); iter->Valid() && i++ < record_count; iter->Next()) {
      iter->value();
    }
    delete iter;
    return kOK;
  }

  int Update(const std::string &table, const std::string &key,
             std::string &values) {
    rocksdb::Status s = this->db->Put(write_option, key, values);
    if (s.ok()) {
      return kOK;
    } else if (s.IsNotFound()) {
      return kErrorNoData;
    }
    return kErrorConflict;
  }

  int Insert(const std::string &table, const std::string &key,
             std::string &values) {
    rocksdb::Status s = this->db->Put(write_option, key, values);
    if (s.ok()) {
      return kOK;
    } else if (s.IsNotFound()) {
      return kErrorNoData;
    }
    return kErrorConflict;
  }

  int Delete(const std::string &table, const std::string &key)
  {
      return 0;
  }

 private:
  rocksdb::DB *db;
  rocksdb::Options option;
  rocksdb::WriteOptions write_option;
  rocksdb::ReadOptions read_option;
};

}  // namespace ycsbc

void UsageMessage(const char *command);
bool StrStartWith(const char *str, const char *pre);
string ParseCommandLine(int argc, const char *argv[], utils::Properties &props);

int DelegateClient(ycsbc::DB *db, ycsbc::CoreWorkload *wl, const int num_ops,
                   bool is_loading) {
  db->Init();
  ycsbc::Client client(*db, *wl);
  int oks = 0;
  printf("is_loading %d, num_ops %d\n", is_loading, num_ops);
  for (int i = 0; i < num_ops; ++i) {
    if (is_loading) {
      oks += client.DoInsert();
    } else {
    //   printf("%d do transaction ", i);
      oks += client.DoTransaction();
    //   printf("transaction done\n");
    }
  }
  if (is_loading)
  {
      printf("loading done, oks: %d\n", oks);
  }
  db->Close();
  return oks;
}

int main(const int argc, const char *argv[]) {
  utils::Properties props;
  string file_name = ParseCommandLine(argc, argv, props);

  ycsbc::DB *db = new ycsbc::RocksDB(props);  // ycsbc::DBFactory::CreateDB(props);
  if (!db) {
    cout << "Unknown database name " << props["dbname"] << endl;
    exit(0);
  }

  ycsbc::CoreWorkload wl;
  wl.Init(props);

  const int num_threads = stoi(props.GetProperty("threadcount", "1"));

  // Loads data
  vector<future<int>> actual_ops;
  int total_ops = stoi(props[ycsbc::CoreWorkload::RECORD_COUNT_PROPERTY]);
  for (int i = 0; i < num_threads; ++i) {
    actual_ops.emplace_back(async(launch::async, DelegateClient, db, &wl,
                                  total_ops / num_threads, true));
  }
  assert((int)actual_ops.size() == num_threads);

  int sum = 0;
  for (auto &n : actual_ops) {
    assert(n.valid());
    sum += n.get();
  }
  cerr << "# Loading records:\t" << sum << endl;

  // Peforms transactions
  actual_ops.clear();
  total_ops = stoi(props[ycsbc::CoreWorkload::OPERATION_COUNT_PROPERTY]);
  utils::Timer<double> timer;
  timer.Start();
  for (int i = 0; i < num_threads; ++i) {
    actual_ops.emplace_back(async(launch::async, DelegateClient, db, &wl,
                                  total_ops / num_threads, false));
  }
  assert((int)actual_ops.size() == num_threads);

  sum = 0;
  for (auto &n : actual_ops) {
    assert(n.valid());
    sum += n.get();
  }
  double duration = timer.End();
  cerr << "# Transaction throughput (KTPS)" << endl;
  cerr << "/tmp/ycsbc_rocksdb_test" << '\t' << file_name << '\t' << num_threads << '\t';
  cerr << total_ops / duration / 1000 << endl;
  printf("\nnum_threads: %d, total_ops: %d, duration: %f\n", num_threads, total_ops, duration);
  printf("%f ops", total_ops/duration);
}

string ParseCommandLine(int argc, const char *argv[],
                        utils::Properties &props) {
  int argindex = 1;
  string filename;
  while (argindex < argc && StrStartWith(argv[argindex], "-")) {
    if (strcmp(argv[argindex], "-threads") == 0) {
      argindex++;
      if (argindex >= argc) {
        UsageMessage(argv[0]);
        exit(0);
      }
      props.SetProperty("threadcount", argv[argindex]);
      argindex++;
    } else if (strcmp(argv[argindex], "-db") == 0) {
      argindex++;
      if (argindex >= argc) {
        UsageMessage(argv[0]);
        exit(0);
      }
      props.SetProperty("dbname", argv[argindex]);
      argindex++;
    } else if (strcmp(argv[argindex], "-host") == 0) {
      argindex++;
      if (argindex >= argc) {
        UsageMessage(argv[0]);
        exit(0);
      }
      props.SetProperty("host", argv[argindex]);
      argindex++;
    } else if (strcmp(argv[argindex], "-port") == 0) {
      argindex++;
      if (argindex >= argc) {
        UsageMessage(argv[0]);
        exit(0);
      }
      props.SetProperty("port", argv[argindex]);
      argindex++;
    } else if (strcmp(argv[argindex], "-slaves") == 0) {
      argindex++;
      if (argindex >= argc) {
        UsageMessage(argv[0]);
        exit(0);
      }
      props.SetProperty("slaves", argv[argindex]);
      argindex++;
    } else if (strcmp(argv[argindex], "-P") == 0) {
      argindex++;
      if (argindex >= argc) {
        UsageMessage(argv[0]);
        exit(0);
      }
      filename.assign(argv[argindex]);
      ifstream input(argv[argindex]);
      try {
        props.Load(input);
      } catch (const string &message) {
        cout << message << endl;
        exit(0);
      }
      input.close();
      argindex++;
    } else {
      cout << "Unknown option '" << argv[argindex] << "'" << endl;
      exit(0);
    }
  }

  if (argindex == 1 || argindex != argc) {
    UsageMessage(argv[0]);
    exit(0);
  }

  return filename;
}

void UsageMessage(const char *command) {
  cout << "Usage: " << command << " [options]" << endl;
  cout << "Options:" << endl;
  cout << "  -threads n: execute using n threads (default: 1)" << endl;
  cout << "  -db dbname: specify the name of the DB to use (default: basic)"
       << endl;
  cout << "  -P propertyfile: load properties from the given file. Multiple "
          "files can"
       << endl;
  cout << "                   be specified, and will be processed in the order "
          "specified"
       << endl;
}

inline bool StrStartWith(const char *str, const char *pre) {
  return strncmp(str, pre, strlen(pre)) == 0;
}
