
## Overview

These are the script form of **[ivanfioravanti/kubernetes-the-hard-way-on-azure⇗](http://github.com/ivanfioravanti/kubernetes-the-hard-way-on-azure)**.

Benefits over the original copy-and-paste:

   * Faster to run script than copy-and-paste
      * Faster to achive same steps once you've learned it
      * Can drop and re-create environment easily to save cost
   * Scripts are idempotent (e.g. ```az network vnet create``` is **not** idempotent)
   * Idempotent makes it possible to verify and incrementally build
   * The commands in the scripts have **not** been parameterised
      * to allow running manually when needed for demo


## Getting Started

   1. (Optional) edit ```000-values.sh``` and set ```SUBS_GUID```
      - Stops scripts being run on wrong subscription
   1. Run ```./010-resource-group.sh``` - prompts to create resource group
      - Sets Azure location (Region) for subsequent resources
      - All resources default to the resource group's location
   1. Run the next script, e.g. ```./020-client-tools.sh``` etc.
   1. Cleanup: run the ```./099-drop-resource-group.sh```
      - Drops the resource group AND everything in it.

