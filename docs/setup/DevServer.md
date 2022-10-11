# Set up the Dev Server

The Dev Server needs to be set up for data parsing and report generation. NVLeak scripts use MongoDB to store the parsed data, and then fetch the useful data from MongoDB to generate plots.

## Set Up the MongoDB

You may use the Docker compose file to set up the MongoDB:

1. Install the Docker and `docker-compose` on your Dev Server
2. Update the Docker compose file `NVLeak/docker/MongoDB.yml` with your username, password, and data storage path for the MongoDB
3. Boot up the MongoDB by:

   ```shell
   $ cd NVLeak/docker
   $ bash up.sh
   Recreating docker_mongo_1         ... done
   Recreating docker_mongo-express_1 ... done
   ```

4. (Optional) If you'd like to browse the MongoDB for maintenance or updates, you may try JetBrains DataGrip or other GUI tools.
5. Update the parser script `NVLeak/scripts/parse/radar/utils.py` with MongoDB connection info (username, password, URL, and port).

## Install Required Packages

1. Install the following python packages

   ```shell
   $ pip3 install click editdistance numpyencoder pandas pymongo
   ```
