#! /bin/bash

function link_data() {
    ln -s "../../../../data/side_sqlite/results/${1}/summary.csv" "${2}.csv"
}

link_data       20221011-23-36-50       C1 # count       -> C1
link_data       20221011-23-37-19       S1 # sort        -> S1
link_data       20221011-23-37-49       Q1 # query       -> Q1
link_data       20221011-23-38-18       I2 # insert1000  -> I2
link_data       20221011-23-38-49       I1 # insert10000 -> I1
link_data       20221011-23-39-19       U1 # update100   -> U1
link_data       20221011-23-39-50       U2 # update1000  -> U2
