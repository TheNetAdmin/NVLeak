#! /bin/bash

function link_data() {
    ln -sf "../../../../data/side_sqlite/results/${1}/summary.csv" "${2}.csv"
}

link_data       20221114-01-07-57     M1 # month1 -> M1
link_data       20221114-01-18-14     M2 # month2 -> M2
link_data       20221114-01-28-32     M3 # month3 -> M3
link_data       20221114-01-38-49     M4 # month4 -> M4
