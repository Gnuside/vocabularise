vocabulari.se
============

The social network of your research objects
-------------------------------------------

Vocabulari.se is a search tool addressed to researchers to explore a social network of research objects, help them choose the wording of their abstracts or the tagging of their papers, and discover their research interests in new ways. This tool is grounded in “science studies” , which show that research objects have a social, even political, life of their own… let us play with it! And open the black box of the ubiquitous yet poor tagging system as the ultimate linking device of words…

vocabulari.se searches for terms related to a given term (i.e. a research object, treated as a Mendeley tag or a Wikipedia entry) according to three qualities of relationships:

* Unexpected relationships (i.e. not frequent yet effective) that give originality to research
* Controversial relationships (i.e most discussed on Wikipedia) that widen the audience ;
* Aggregating relationships (i.e. most multidisciplinary Mendeley associations) that bridge the gap with other disciplines' interests.

The classifications are reversible since it may be preferred to know about expected, uncontroversial or disaggregating relationships. It is up to you!


And for the geeks among you...
------------------------------

vocabulari.se is a mash-up of Mendeley and Wikipedia APIs. Our algorithms start
from an ensemble of related tags obtained through co-occurrence analysis in
Mendeley data. Then we sort the results through the slope of frequency vs.
readership relationship (algorithm 1), through the size of Wikipedia discussion
pages resulting from querying two related tags (algorithm 2), through the
multidisciplinarity of Mendeley publications readership (algorithm 3).

The code of vocabularise is published under the GNU Affero GPL license. 

Hence you can (and are invited to) contribute improvements, implement your own
version of the tool or dissect our amazing algorithms :-) 

Credits
-------

* Original idea & project lead : Axel Meunier and [Deuxi&egrave;me labo](http://www.deuxieme-labo.fr)
* Algorithms & development : [Gnuside](http://www.gnuside.com)
* Graphic design : Jérémie Elalouf
* Technical advice : Pierre Maumont

We also thank Jonathan Parienté, Joël Gombin, Emmanuel de Maistre and Matthieu Rouchouse for their support, food and conversation.

vocabulari.se is dedicated to Mendeley, Wikipedia, and everyone who made them possible. It is not, however, dedicated to those who lock down scientific publications and humanity’s knowledge.

