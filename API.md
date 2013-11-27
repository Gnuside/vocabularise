Vocabularise API
================

Some interesting URL, if you want to directly access computed data :

1. /search/expected
-------------------

Search returns words co-tagged unfrequently yet effectively with the query in
research publications, ranked according to readership on Mendeley, and the
associated publications.


### Examples 

  * http://vocabulari.se/search/expected?query=neutrino
  * http://vocabulari.se/search/expected?query=climate%20change


### Method

<table>
    <tr>
	<th>URI</th>
	<th>Method</th>
	<th>Authentication</th>
    </tr>
    </tr>
	<td>http://vocabulari.se/search/controversial</td>
	<td>GET</td>
	<td>none</td>
    </tr>
</table>


### Parameters

<table>
    <tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Description</th>
    </tr>
    </tr>
	<td>query</td>
	<td>String</td>
	<td>A tag to be searched</td>
    </tr>
</table>


### Response example

    {
	"result":[
	    [
		"opera",{
		    "views":263,
		    "links":[
			{
			"url":"http://api.mendeley.com/research/measurement-neutrino-velocity-opera-detector-cngs-beam/",
			"text":"Measurement of the neutrino ..."
			}
		    ],
		    "apparitions":1,
		    "slope":0.00380228136882129
		}
	    ]
	],
	"algorithm":"expected"
    }


/search/controversial
---------------------

Search returns words co-appearing with the query in the most discussed
Wikipedia entries, according to controversial power, and the associated
entries.


### Examples

  * http://vocabulari.se/search/controversial?query=neutrino
  * http://vocabulari.se/search/controversial?query=climate%20change

### Method

<table>
    <tr>
	<th>URI</th>
	<th>Method</th>
	<th>Authentication</th>
    </tr>
    </tr>
	<td>http://vocabulari.se/search/controversial</td>
	<td>GET</td>
	<td>none</td>
    </tr>
</table>


### Parameters

<table>
    <tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Description</th>
    </tr>
    </tr>
	<td>query</td>
	<td>String</td>
	<td>A tag to be searched</td>
    </tr>
</table>


### Response example

    {
        "result":[
            [
                "opera",{
                "links":[
                    {
                        "url":"http://en.wikipedia.org/wiki/OPERA neutrino anomaly",
                        "text":"OPERA neutrino anomaly"
                    },
                    {
                        "url":"http://en.wikipedia.org/wiki/Neutrino",
                        "text":"Neutrino"
                    },
                    {
                        "url":"http://en.wikipedia.org/wiki/OPERA experiment",
                        "text":"OPERA experiment"
                    }
                ],
                "hotness":38
                }
            ]
        ],
        "algorithm":"controversial"
    }


3. /search/aggregating
----------------------

Search returns words co-tagged with the query in research publications, ranked
according to the diversity of readers&rsquo; disciplines on Mendeley, and the
associated disciplines.


### Examples

  * http://vocabulari.se/search/aggregating?query=neutrino
  * http://vocabulari.se/search/aggregating?query=climate%20change

### Method

<table>
    <tr>
	<th>URI</th>
	<th>Method</th>
	<th>Authentication</th>
    </tr>
    </tr>
	<td>http://vocabulari.se/search/aggregating</td>
	<td>GET</td>
	<td>none</td>
    </tr>
</table>


### Parameters

<table>
    <tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Description</th>
    </tr>
    </tr>
	<td>query</td>
	<td>String</td>
	<td>A tag to be searched</td>
    </tr>
</table>


### Response example

A simple response example :

    {
        "result" : [
            [
                "opera",
                {
                    "disc_list":[
                        [
                            "Astronomy / Astrophysics / Space Science",
                            {"value":11,"count":1}
                        ],
                        [
                            "Biological Sciences",
                            {"value":10,"count":1}
                        ]
                    ],
                    "links":[
                        {
                            "url":"http://www.mendeley.com/biologicalsciences/",
                            "text":"Biological Sciences"
                        },
                        {
                            "url":"http://www.mendeley.com/astronomy/astrophysics/spacescience/",
                            "text":"Astronomy / Astrophysics / Space Science"
                        },
                        {
                            "url":"http://www.mendeley.com/physics/",
                            "text":"Physics"
                        }
                    ],
                    "disc_count":2,
                    "disc_sum":21
                }
            ]
        ],
        "algorithm":"aggregating"
    }

