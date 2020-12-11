# RoactRodux Changelog

## Current master
* Added feature to parameter `mapDispatchToProps` as an optional table with action creators.
	* The parameter could store a dictionary of functions returning actions which automatically get wrapped with the dispatch callback.

## 0.2.2 (2020-05-14)
* Changed order of connection to store so that Parent components are connected to the store before their children.
	* This should resolve some issues with components receiving bad combinations of props and store state.

## 0.2.1 (2020-03-20)
* Update to latest Rotriever manifest format.

## 0.2.0 (2019-10-24)
* Initial release.
