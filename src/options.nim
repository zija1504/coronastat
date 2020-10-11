import parseopt, os, strutils, strformat
import globals

type
  OptionCallback* = proc(val: string)

  Option* = object
    long*: string
    short*: string
    description*: string
    callback*: OptionCallback

var
  options*: seq[Option]
  countryInput* = ""
  showNew* = false
  showLastUpdate* = false

proc getOptionLength(option: Option): int =
  return option.short.len + option.long.len

proc getLongestOption(): int =
  result = 0
  for option in options:
    let len = getOptionLength(option)
    if len > result:
      result = len

proc printVersion() =
  echo &"Coronastat Version {version}"
  echo &"Compiled at {CompileDate} {CompileTime}"
  echo &"Author: {author}"

proc versionCallback(val: string) =
  printVersion()
  quit()

proc helpCallback(val: string) =
  printVersion()
  echo "\nOptions:"

  for option in options:
    stdout.write(&"\t-{option.short}, --{option.long}")
    
    let descPos = getLongestOption() + 4
    let diff = descPos - getOptionLength(option)

    stdout.write(' '.repeat(diff))
    echo option.description

  quit()

proc parseCommandLine*() =
  options.add Option(long: "version", short: "v", description: "shows version info", callback: versionCallback)
  options.add Option(long: "help", short: "h", description: "shows help", callback: helpCallback)
  options.add Option(long: "country", short: "c", description: "set country(if set to all -> shows information about all countries)", callback: (proc (val: string) = countryInput = val))
  options.add Option(long: "new", short: "n", description: "shows new data(only works if a country is specified)", callback: (proc (val: string) = showNew = true))
  options.add Option(long: "lastupdate", short: "l", description: "shows when was the last update(only works if a country is not specified)", callback: (proc (val: string) = showLastUpdate = true))

  let args = commandLineParams().join(" ")

  var opt = initOptParser(args)

  while true:
    opt.next()
    case opt.kind
      of cmdEnd: break
      of cmdShortOption:
        for option in options:
          if option.short == opt.key:
            option.callback(opt.val)
      of cmdLongOption: 
        for option in options:
          if option.long == opt.key:
            option.callback(opt.val)
      of cmdArgument: break