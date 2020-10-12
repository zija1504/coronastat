import json, httpclient, times, strformat, strutils, unidecode
import options, table, globals

var 
  client = newHttpClient()
  node: JsonNode
  cases: int
  deaths: int
  recovered: int

proc world(): string =
  cases = node["cases"].getInt()
  deaths = node["deaths"].getInt()
  recovered = node["recovered"].getInt()

  result = fmt"cases: {cases} ; deaths: {deaths} ; recovered: {recovered}"

  if showLastUpdate:
    let 
      unixStart = parse("1970-01-01", "yyyy-MM-dd")
      now = initDuration(milliseconds = node["updated"].getInt)
      lastUpdated = $(unixStart + now)

    result &= fmt" ; last updated: {lastUpdated}"

proc countryOrContinent(): string =
  cases = node["cases"].getInt()
  deaths = node["deaths"].getInt()
  recovered = node["recovered"].getInt()

  result = fmt"cases: {cases} ; deaths: {deaths} ; recovered: {recovered}"

  if showNew:
    var
      newCases  = node["todayCases"]
      newDeaths = node["todayDeaths"]

    result &= fmt" ; new cases: {newCases} ; new deaths: {newDeaths}"

proc allCountriesOrContinents(coc: string) =
  var 
    counOrCont: seq[seq[string]]
    idx = 1
    headers = @["", coc, "cases", "deaths", "recovered"]

  if showNew:
    headers.add "new cases"
    headers.add "new deaths"

  for item in node.items:
    var row: seq[string]
    row.add intToStr(idx)
    row.add unidecode(item[coc].getStr)
    row.add intToStr(item["cases"].getInt)
    row.add intToStr(item["deaths"].getInt)
    row.add intToStr(item["recovered"].getInt)

    if showNew:
      row.add intToStr(item["todayCases"].getInt)
      row.add intToStr(item["todayDeaths"].getInt)

    counOrCont.add row
    inc idx

  printTable(headers, counOrCont)

parseCommandLine()

case countryInput:
  of "none":
    case continentInput:
      of "none":
        let data = client.getContent(requestURL & "all")
        node = parseJson(data)
        echo world()
      of "all":
        let data = client.getContent(requestURL & "continents")
        node = parseJson(data)
        allCountriesOrContinents("continent")
      else:
        let data = client.getContent(requestURL & "continents/" & continentInput)
        node = parseJson(data)
        echo countryOrContinent()

  of "all":
    let data = client.getContent(requestURL & "countries")
    node = parseJson(data)
    allCountriesOrContinents("country")
  else:
    let data = client.getContent(requestURL & "countries/" & countryInput)
    node = parseJson(data)
    echo countryOrContinent()