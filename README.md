# InternFair

### database commands

`docker exec -t your-db-container pg_dumpall -c -U postgres > dump_data.sql`

`cat dump_data.sql | docker exec -i 748e6ca904d3 psql -U postgres`


### git commands


`git clone https://github.com/joeydash/gps_module_logging.git && cd gps_module_logging`


`git add *`

`git commit -m "added by me"`

`git push origin master`