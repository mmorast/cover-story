cover-story: Code coverage dashboard (soon?)
===========

This is rough on purpose for now.  Things that are in place:

#### CONFIG (config/config.yml)

The config file is very important. It defines:
- file Matchers for import
- directory locations for file import


#### SCOPING:
By default only valid (active/not ignored) ImportCollections and
Analysis records will show. Rails default scoping has been set at
the model level.  An Analysis record's validity is tied to the
ImportCollection it belongs to.  The short: if you tag something to
be ignored, it will behave as if deleted unless you apply unscoped


#### IMPORT:
We will rely entirely on file drop for import.  

For the file drop to work, the daemon needs to be running.  See:
- lib/daemons/file_import_watcher.rb.  

You can run it with:
- RAILS_ENV=development ruby lib/daemons/file_import_watcher.rb

The file drop uses ImportService (app/services/import_service.rb).
This service drives the importing of all accepted files:
- log_something.log
- routes_something.txt
- meta_something.txt
- something.zip (the zip file MUST contain at least one of each of the above)

Right now the main import service funnels things downwards to the log,
routes, and (not implemented yet) meta file import services.  Whether
or not we consolidate all this into a single service and push the rest
down to /lib is TBD.  /lib definitely needs to be organized a bit better
and in perpetual progress.

Upon import, the following tables get updated, important columns noted:

##### Import Collection:
import_collections: This is the core record that Logs and Meta tie to

##### Routes:
- routes (columns: path, controller - both of which are formatted)
- route_histories (activated, inactivated)

##### Logs:
- sources aka LogSource (env, ignore, import collection id)
- started_lines aka LogStartedLine (formatted path)
- processing lines aka LogProcessingLine (controller)

##### Meta:
TBD,
but right now anything this could populate is budled within ImportCollections


#### ANALYSIS
Analysis happens automatically after a file import containing a log
file (test or production). Each import generates a single Analysis
record per log file & application. An analysis record stores
(see model/analysis, lib/analyzers/calculator):
- associated import collection id
- application (hr suite, applicant portal, employee portal, defined in config.yml)
- tested controllers percentage
- tested paths percentage
- used controllers percentage
- used paths percentage
- tested used controllers percentage
- tested used paths percentage
- used controllers percentage all time
- used paths percentage all time
- tested used controllers percentage all time
- tested used paths percentage all time

we can also pull:
- untested_paths
- untested controllers
- untested used paths
- untested used controllers

We only work with valid Analysis records. See scoping section.


#### VIEW
TBD.
Right now it is the ugliest, slightly misaligned graph that allows
hovering over nodes in the crudest of ways.  We ONLY show the percentage
covered, and may not even filter it correctly by analysis type right now.


#### RAKE tools (examples):
- rake import:clear:logs/routes/all
- rake analyze:clear:all will clear all analysis data
- rake import:logs/routes (need to specify file)


#### TODO:
- TESTS!!!! we need this around each of our specific requirements (sorry)
- ignore: how to tag files as ignored
- meta file - what do we want to expect in here
- general cleanup/consolidation of lib/services
