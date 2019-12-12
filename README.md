# walmart_tools
Tools for Walmart Photo Technical Support - any suggestions welcome!

## image_album
Check and download images in an album manually
Instructions on how to create the JSON array of URLs is in the help text of the tool, also below:
  1) Navigate to customer album in Site Management interface
  2) Open the console and run the following JS to copy the array to your clipboard:
      x = document.getElementsByClassName('photos')[0];
      y = [];
      for (var i = 0; i < x.children.length; i++) {
        y.push(x.children[i].src)
      };
      copy(y)
  3) Paste this into a JSON file (i.e. something.json)
  4) Run this tool specifying the JSON's filepath with -f

Usage:
- See help text
    $ ruby bin/image_album -?

- Check album images
    $ ruby bin/image_album -C -f tmp/something.json

- Download album images
    $ ruby bin/image_album -D -f tmp/something.json   ## Album zip will appear in output/image_album/album_date.zip

- Check album images and download the available ones to a specific file location
    $ ruby bin/image_album -C -D -f tmp/something.json -o /home/horatio/something.zip
