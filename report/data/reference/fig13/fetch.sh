#! /bin/bash

function link_data() {
    ln -s "../../../../data/side_sqlite/results/${1}/summary.csv" "${2}.csv"
}

link_data       20221011-23-40-20     M1 # month1 -> M1
link_data       20221011-23-51-44     M2 # month2 -> M2
link_data       20221012-00-03-08     M3 # month3 -> M3
link_data       20221012-00-14-30     M4 # month4 -> M4
