# Database Tool 

a univeral database manage tool for windows.



**note**: this repository is not open for contribute. if any changes you wanna to make, just fork this repo.



## License

MIT

## Compile from source
1. requires RAD studio 11+ with Delphi
## Usage 
put binary at some folder like:
```
dbtool/
	dbtool.exe
	dbtool.ini //must same name as binary file and with extension 'ini'
	... //other resources if use relative folder for database binaries
```
see `DbTool.template.ini` for example

## Examples

### MongoDB

```ini
[Mongo]
;the folder store data
param_db=D:\store\
;the process name
proc_exec=mongod.exe
;put mongo binary under {ROOT}/mongo/
;those binary file are required: 
; mongod.exe,mongodump.exe,mongorestore.exe,mongofiles.exe,mongostat.exe,bsondump.exe,mongod.config
;those file not checked for requirement:
; mongoimport.exe,mongos.exe,mongos.exe,mongo.exe,mongoexport.exe,mongotop.exe,mongostat.exe
;also create a folder {ROOT}/logs which store logs
cmd_launch=@mongo\mongod.exe --dbpath "%0:s" --logpath @logs\monogodb.log --logappend
cmd_backup_ol=@mongo\mongodump.exe --out "%0:s"
cmd_restore_ol=@mongo\mongorestore.exe --quiet --drop "%0:s"
;put 7zip at {ROOT}/7z with those files
;7z.dll,7z.exe
cmd_arc=@7z\7z.exe a -y -mx9 -r -sdel -ssw "%0:s" "%1:s/*"
cmd_unarc=@7z\7z.exe x -y -aoa -r -o"%1:s" "%0:s"
```

### Postgres

```ini
[Postgres]
;the folder store data
param_db=D:\store\
;the process name
proc_exec=postgres.exe
;put postgres files under {ROOT}/pgsql/;
;required folders are: bin/ , lib/, share/;
;create a text file with one line of your password for initialize database;
;also create a folder {ROOT}/logs which store logs;
proc_exec=postgres.exe
cmd_init=@pgsql\bin\pg_ctl.exe init -D "%0:s" -o "-U postgres --pwfile @pgsql\pwd -E UTF8"
cmd_launch=@pgsql\bin\pg_ctl.exe start -D %0:s -l @logs\postgres.log
cmd_stop=@pgsql\bin\pg_ctl.exe stop -D "%0:s"
;backup are not tested yet
```

