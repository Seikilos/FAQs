Skip lists memory issues
================================

**Declare the item variable first. If you don't do it, the code will run but the result will be broken**

```
// If you comment this line, you will get random data in item
string item

for item in skiplist do {
  // Get key this way
  TYPE k = (TYPE key skiplist)
  print "Value: " item " , Key:" k "\n"
}
```
