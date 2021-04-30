## ParameterCounter

Version 1.0
Created by Charlie Hall
https://www.github.com/charlie9830
Last Updated April 2021

Source Code available at:
https://github.com/Charlie9830/ParameterCounter


## DESCRIPTION
This plugin for MA Lighting GrandMA2 consoles will collate the parameter count of only the universes that have been "Requested" in the DMX Universe Pool.


## IMPORTANT
Due to how MA calculates parameters for FixtureTypes with 'Virtual Channels', this plugin cannot correctly count parameters
for FixtureTypes with 'Virtual Channels'. If you have a number of FixtureTypes with 'Virtual Channels' the parameter count
reported by this plugin will be LESS then what the actual parameter count is.