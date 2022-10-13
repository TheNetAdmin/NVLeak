#! /bin/bash

function link_data() {
    ln -s "../../../../data/side_sqlite/results/${1}/summary.csv" "${2}.csv"
}

link_data       <FILL_TASK_ID_HERE>     M1 # month1 -> M1
link_data       <FILL_TASK_ID_HERE>     M2 # month2 -> M2
link_data       <FILL_TASK_ID_HERE>     M3 # month3 -> M3
link_data       <FILL_TASK_ID_HERE>     M4 # month4 -> M4
