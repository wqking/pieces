# NSIS installer script for MT4 EA and Indicators

This is a very simple NSIS (Nullsoft Scriptable Install System) script to create Windows installer for MetaTrader 4 Expert Advisors and Indicators.  
If your EA or indicator includes more than just one .ex4 file, such as, a bunch of DLLs, you may want to pack them into a installer.  
I used the script in my Adaptive RSI indicator http://www.kbasm.com/adaptive-rsi/index.html and will use it for all future products (my EAs and indicators depend on Qt DLLs).  

The main script is installer.nsh. Check sample.nsi to see how to use the script.

Main features:
  - Auto detect MT4 data folder in {AppPath}\MetaQuotes\Terminal and {AppPath}
  - Display the folder in a friendly way, with MT4 install folder prefixed. For example, <C:\Program Files (x86)\SomeBrokerMetaTrader> c:\users\blah blah.
  - Easy to use, no config, just include the main script.

Known issues:
  - The UI uses the old nsDialog, not Modern UI.
  - The main window looks quite small.
  - Only support the new folder structure for MT4 Build 600+.

### License

The license is same as my another C++ library cpgf, it's Apache License, Version 2.0.
