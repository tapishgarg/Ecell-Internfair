# InternFair

### database commands

```bash
docker exec -t $(docker ps | awk -v app="postgres" '$2 ~ app{print $1}') pg_dumpall -c -U postgres > dump_data.sql


cat dump_data.sql | docker exec -i $(docker ps | awk -v app="postgres" '$2 ~ app{print $1}') psql -U postgres
```


### git commands

```bash

git clone https://github.com/joeydash/Ecell-Internfair.git && cd Ecell-Internfair

git add *

git commit -m "added by me"

git push origin master
 
```