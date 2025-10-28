# QS_location_list
R script to request the RDF datastream for locations

RISearch is only able to access the DC datastream for locations, which only contains <dc:title> and <dc:coverage>. 
Most of the useful searchable data is in the RDF datastream (especially <schema:alternateName> and <schema:description>), which is not accessible via RISearch.
This script uses the API to request the RDF datastream for each qsr-place (from a list previously created by an RISearch query) and generate a CSV to make searching for places easier.

The qsr-place list (in /data) was up to date as of October 2025.  If more addresses are added to QuakeStudies later, the list will need to be recreated, using the Sparql query:

```
SELECT ?place ?title ?coverage
WHERE {
  ?place <http://purl.org/dc/elements/1.1/coverage> ?coverage .
  ?place <http://purl.org/dc/elements/1.1/title> ?title .
  ?place <info:fedora/fedora-system:def/model#hasModel> <info:fedora/quakestudies:placeCModel>
}
```
