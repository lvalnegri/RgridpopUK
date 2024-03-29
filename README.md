## RgridpopUK

An $R$ package with a few functionalities on how to download, prepare, and visualize data about Population in England and Wales at micro grid levels of 30 meters, as published by the [Humanitarian Data Exchange](https://data.humdata.org/) on behalf of [Data for Good at Meta (previously Facebook)](https://data.humdata.org/organization/74ad0574-923d-430b-8d52-ad80256c4461), either as a Total, or segmented by Sex and Age as follows:
 - Males 
 - Females 
 - Children (ages 0-5)
 - Youth (ages 15-24)
 - Elderly (ages 60+)
 - Women of reproductive age (ages 15-49)

The package also contains:
 - a table `zones` with all 7,264 *Middle-Layer Super Output Areas*, or `MSOA`, in England and Wales as of Census 2021, with some of their main geographic and demographic characteristics.
 - a processed version, converted in `sf` format suitable for $R$ analysis and *RMarkdown* or *Shiny* application, of the Census 2021 digital boundaries MSOA` 
 
For more information, see: 
 - the [ONS website](https://www.ons.gov.uk/methodology/geography/ukgeographies/censusgeographies/census2021geographies) for more information about the Census hierarchy geographic structure 
 - the [ONS geoportal](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=name&tags=all(BDY_MSOA%2CDEC_2021)) for the original geographic files
 - the [House of Commons Library](https://houseofcommonslibrary.github.io/msoanames/) for more *presentable* names for `MSOA`.

The package is not on `CRAN`. To install the package:
```
remotes::install_github('lvalnegri/Rgridpopuk')
```
The total needed storage is about 2.2GB.

A *Shiny* app is also included, ready to run as soon as the data have been correctly processed. 


### Attributions

 - Facebook Connectivity Lab and Center for International Earth Science Information Network - CIESIN - Columbia University. 2016. High Resolution Settlement Layer (HRSL). Source imagery for HRSL © 2016 DigitalGlobe. Accessed 15 Dec 2022."

 - Contains OS data © Crown copyright and database rights 2023 
 
 - Source: Office for National Statistics licensed under the [Open Government Licence v.3.0](http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/)

 - Contains Parliamentary information licensed under the [Open Parliament Licence v3.0](https://www.parliament.uk/site-information/copyright/open-parliament-licence/)
