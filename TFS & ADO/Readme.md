Administration of TFS and ADO
=================

Deletion of broken Collection
-------------------
Admin cmd / ps in 

```
cd "%programfiles%\microsoft team foundation server NUMBER\tools"
TFSConfig Collection /delete /collectionName:[COLLECTION NAME]
```


If this fail, *create backup of TFS_Collection first* then execute queries on this database:

```sql
select * from tbl_Database
select * from tbl_ServiceHost
select * from tbl_CatalogResource
select * from tbl_GroupScope
select * from tbl_HostResolutionEntry
select * from tbl_JobDefinition
select * from tbl_PropertyValue
```
and delete all rows for database that prevents the deletion. If the database itself exists, delete it as well.

SQL
---------------
* Permission on Server are not automatically inherited to single databases and must be set individually

