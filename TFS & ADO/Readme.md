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
DECLARE @CollectionName varchar(60)
SET @CollectionName = 'the Database name set in the Edit Settings dialog'

select * from tbl_Database where DatabaseName LIKE '%;'+@CollectionName
select * from tbl_ServiceHost where Name = @CollectionName
select * from tbl_CatalogResource WHERE DisplayName =  @CollectionName
select * from tbl_GroupScope where name = REPLACE(@CollectionName, '_', '>')
select * from tbl_HostResolutionEntry where HostKey = '/'+@CollectionName+'/'
select * from tbl_JobDefinition where JobName LIKE '%'+@CollectionName+','
select * from tbl_PropertyValue WHERE LeadingStringValue LIKE '%'+@CollectionName
```
ensure, no wrong rows accross those tables were selected. Then replace select by *delete*

SQL
---------------
* Permission on Server are not automatically inherited to single databases and must be set individually

Transaction log is full
-----------------
Perform full backup, see https://blog.atwork.at/post/SQL-Server-The-transaction-log-for-database-is-full
