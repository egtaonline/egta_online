EGTA Online: A Ruby on Rails Web App for Managing Game Simulation
=================================================================

Upgrade Notes:
* Moving all file I/O to json
  - Simulation Input
    + simulation\_spec.yaml is now simulation\_spec.json
    + example simulation\_spec.json:
    ```
      {
          "assignment":{
              "Bidder":[
                  "Shade1",
                  "Shade1",
                  "Shade2"
              ],
              "Seller":[
                  "FirstPrice",
                  "FirstPrice",
                  "FirstPrice",
                  "SecondPrice"
              ]
          },
          "configuration":{
              "key1":"value"
              "key2":"other value"
          }}
    ```
    + No longer 'numeralizing' by default.  All keys and values in simulation\_spec.json will be strings.
  - Simulation Output
    + Observations are now the unit of output.  The 'payoff_data' file and 'features' folder are not supported anymore.  Observations are json files that include the word 'observation' and carry the json extension.  In other words 'some\_observation.json' and 'observation1.json' are both acceptable naming conventions.  An observation includes all the payoff and feature data from a single observation of the simulator.
    + Observations now record each player separately and aggregate over symmetry inside EGTAOnline.  This provides greater flexibility for statistical procedures.
    + Observations now support arbitrary data for feature observations, though built-in tools currently only work with numerics.
    + example observation.json:
    ```
      {
      	"players": [
      		{
      			"role": "Buyer",
      			"strategy": "BidValue",
      			"payoff": 2992.73,
      			"features": {
      				"featureA": 0.001,
      				"featureB": [2.0, 2.1]
      			}
      		},
      		{
      			"role": "Seller",
      			"strategy": "Shade2",
      			"payoff": 2924.44,
      			"features": {
      				"featureA": 0.003,
      				"featureB": [1.4, 1.7]
      			}
      		},
      		{
      			"role": "Buyer",
      			"strategy": "BidValue",
      			"payoff": 2990.53,
      			"features": {
      				"featureA": 0.002,
      				"featureB": [2.0, 2.1]
      			}
      		},
      		{
      			"role": "Seller",
      			"strategy": "Shade1",
      			"payoff": 2929.34,
      			"features": {
      				"featureA": 0.003,
      				"featureB": [1.3, 1.7]
      			}
      		}
      	],
      	"features": {
      		"featureA": 34,
      		"featureB": [37, 38],
      		"featureC": {
      			"subfeature1": 40,
      			"subfeature2": 42
      		}
      	}
      }
    ```
* Dealing with 2 factor authentication
  - Since CAC is forcing 2 factor authentication, any admin must acquire the following:
    + An account on CAC
    + Membership in the wellman group
    + An MToken
  - Account pooling is now disabled since it would require making everyone re-authenticate on any server restart or broken connection.

Innovations/Special Features

* Enables simple, distributed scheduling of game simulations onto nyx clusters
  - Simulators uploaded to web app are set up on the nyx clusters, ensuring correct permissions
  - Simulations are a request of the simulator to record a number of observations of a particular profile with specified run time parameters.
      + Simple file I/O format allows simulators written in any language to be integrated into this system
      + Payoff data observations, as well as observations of feature variables, are associated with a db record of the profile that was simulated
  - Run time configurations can be adjusted in the web app, with defaults specified by the simulator that is uploaded
  - Provides a gui for configuring simulation job requests that get converted into PBS requests of the cluster
  - Account pooling to maximize throughput of simulations on nyx
  - Simulation errors can be checked in the web app


* GameScheduler construct allows a compact specification of the profile space to sample in terms of strategies
  - Supports role symmetric profile construction, a super set of asymmetric and symmetric profiles
  - Adds another layer of simulation scheduling control
      + Can specify the total number of samples to gather and the number of samples to gather per PBS request
      + Automatically reschedules failed simulations
      + Schedulers respect previously gathered samples as well as other active schedulers, so profile spaces can overlap without concern
  - HierarchicalScheduler construct allows the construction of profiles of the full game, but restricted to the set of profiles consistent with a hierarchical reduction
  - Upcoming json API will allow scripts to schedule arbitrary profiles through http requests
      + These scheduling decisions can be made in concert with analysis conducted in the egat web service, allowing us to close the loop between scheduling and analysis


* Database-backed profile store supports construction of empirical games
  - Profiles, not games, are the primary entity, encouraging sample re-use where appropriate
  - Profile uniqueness is defined by simulator, role/strategy assignment, and run time configuration.  This means that multiple schedulers can request samples of the same profile, but samples that were generated with different versions of a simulator or different run time configuration are stored on a separate profile record.
  - Games are 2-step aggregation filters for profiles, allowing sampled profiles to be part of many games simultaneously
      + The first filter: As new profiles are created they are added to matching^ games, amortizing the cost of looking for profiles that match games
      + The second filter: Among profiles that are matched to a game, when a game representation is requested, profiles are filtered to those that a.) have been sampled and b.) reside in the space defined by the roles and strategies of the game.  This is done through a db query, using a **regular expression to represent the entire profile space**, for speed.
      + As profiles add samples from simulations, the game representation is automatically updated since the game just selects and filters profiles
  - Games can be constructed in stages, allowing analysis to inform decisions about which profiles to sample next
  - Games can currently be downloaded in 3 formats: egat xml, json, and json with full sample records.  This last representation is useful for performing variance reduction.

^Matching here means the objects in question have the same simulator, run time configuration, and number of players.