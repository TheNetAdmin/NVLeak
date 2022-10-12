#! /bin/bash

function link_data() {
    ln -s "../../../../data/side_sqlite/results/${1}/summary.csv" "${2}.csv"
}

link_data       <FILL_TASK_ID_HERE>     C1 # count       -> C1
link_data       <FILL_TASK_ID_HERE>     S1 # sort        -> S1
link_data       <FILL_TASK_ID_HERE>     Q1 # query       -> Q1
link_data       <FILL_TASK_ID_HERE>     I2 # insert1000  -> I2
link_data       <FILL_TASK_ID_HERE>     I1 # insert10000 -> I1
link_data       <FILL_TASK_ID_HERE>     U1 # update100   -> U1
link_data       <FILL_TASK_ID_HERE>     U2 # update1000  -> U2
