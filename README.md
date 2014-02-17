# EVE Map Data

A graph of [EVE Online](http://www.eveonline.com/)'s (non-wormhole) systems in JSON format (both pretty-printed and "compressed"), generated from the [static data export](http://wiki.eve-id.net/CCP_Static_Data_Export).

In addition to a map of all systems in `data/universe.json`/`data/universe_pretty.json`, there are also individual files for each region in, eg, `tenerifis.json`/`tenerifis_pretty.json`.

The given `convert.rb` script reads from a local sqlite database. Used a conversion of CCP's export from https://www.fuzzwork.co.uk/dump/rubicon-1.2-94438/
