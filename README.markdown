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
        + Observations are now the unit of output.  The 'payoff_data' file and 'features' folder are not supported anymore.  Observations are json files that include the word 'observation' and carry the json extension.  In other words 'some\_observation.json' and 'observation1.json' are both acceptable naming conventions.  An observation includes all the payoff and feature data from a single sample of the simulator.
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
    - Simulator defaults should be provided by a file called defaults.json in your zipped simulator
        + Example defaults.json:
    
        ```
        {
            "configuration": {
                "Parm1": 23,
                "Parm2": true,
                "Parm3": "night time"
            }
        }
        ```
* Dealing with 2 factor authentication
    - Since CAC is forcing 2 factor authentication, any admin must acquire the following:
        + An account on CAC
        + Membership in the wellman group
        + An MToken
    - Account pooling is now disabled since it would require making everyone re-authenticate on any server restart or broken connection.
    - It is essential that ~/.ssh/config includes the line `ServerAliveInterval 60`
* Nomenclature changes
    - Jobs are now prefixed with 'egta-' instead of 'mas-'
    - Instead of RoleInstances and StrategyInstances, with payoff data stored in SampleRecords, Profiles now have SymmetryGroups which feature Player records.  A SymmetryGroup of a Profile is identified by a unique role-strategy pair, specifies the number of players in one observation of the SymmetryGroup, and has a collection of Players.  A Player is an observation of a member of a SymmetryGroup and includes an observation\_id, payoff, and features.
    - The field parameter\_hash has been changed throughout to configuration, since a.) this matches the nomenclature from the EGTAOnline paper and b.) hash is a language-specific word that carries other definitions.  In Ruby it refers to the datatype that is called a 'dict' in Python, and a 'map' in Java and other languages.
    - What was previously known as a Profile's name is now known as its assignment.  This is to reinforce the idea that assignments are not unique identifiers.  A Profile is 'named' by its simulator, configuration, and assignment.
* Changes in the scheduling API
    - Any reference to 'parameter\_hash' should be replaced with 'configuration'
    - Any reference to 'profile\_name' should be replaced with 'assignment'
    - GenericSchedulers now require 'Game size' (aka size).  No scheduling can be conducted with a GenericScheduler until you edit them to specify a size.
    - GenericSchedulers now require a role partition in order to schedule, and may only schedule profiles that match their role partition.
    - As a result of the proceeding 2 points, Games can be now be constructed with 1 click (and soon 1 api call) to match a GenericScheduler.
* Changes to Games
    - Control variates will be temporarily unavailable.  It is being pulled out to be moved to an analysis workflow style approach.
    - There are now 3 JSON formats of games: summary, observation, and full
        + Summary is similar to the existing JSON standard, but reconfigured to more closely match internal profile implementation.
        + Observation is a new format that aggregates over symmetry but keeps observations separate.
        + Full is an extension of the old full format, featuring no aggregation, but including player records, and also reordered a little to match the internal profile implementation.
        + If you wish to see examples of these formats, just send me an email.
    - In place of passing `full=true` with your request to download the game via API, provide `granularity=full` (or `granularity=observation`).
    - Unless there is significant outcry against this, I'm going to stop supporting EGAT XML, since we've mostly moved on to using JSON and python for analysis.
* Final Notes
    - Instructions on the web page are now significantly out of date, so _do not rely on them_.  For now, this page is the primary repository of knowledge about how things work, and you should email me if anything is unclear.  Once everything is basically working I'll update the instruction pages.