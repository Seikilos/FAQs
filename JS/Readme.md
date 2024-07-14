Copy browser context as json (without circular references)
================================
Taken from [stack overflow](https://stackoverflow.com/a/78387892/2416394)

Tested with Chrome and Firefox

Just paste into browsers console window, then your clipboard has the data

**Caveat:** Limited use: This won't work on `navigation` and other properties, that deeply hide their attributes (e.g. non enumerable + inherited)

```js
 function copyWithCircularRefs(input) {
  const getCircularReplacer = () => {
    const seen = new WeakSet();
    return (key, value) => {
      if (typeof value === "object" && value !== null) {
        if (seen.has(value)) {
          // Instead of returning undefined, return a custom placeholder
          return '[Circular]';
        }
        seen.add(value);
      }
      return value;
    };
  };

  // Use the custom replacer function with JSON.stringify
  const stringifiedData = JSON.stringify(input, getCircularReplacer(), 2);

  // Copy the stringified data to the clipboard
  copy(stringifiedData);

  // Log a message to the console to confirm the action
  console.log('Object copied to clipboard');
}

copyWithCircularRefs(this);
```
