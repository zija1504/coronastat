import strutils

proc getColumnWidths(table: seq[seq[string]], headers: seq[string]): seq[int] =
  result = newSeq[int](headers.len)

  for i in 0..table.len - 1:
    for j in 0..headers.len - 1:
      if table[i][j].len > result[j]:
        result[j] = table[i][j].len

  for i in 0..headers.len - 1:
    if headers[i].len > result[i]:
      result[i] = headers[i].len

proc printFillerLine(str: var string, widths: seq[int]) =
  str &= "+"

  for width in widths:
    str &= repeat('-', width + 2)
    str &= "+"

  str &= "\n"

proc printLine(str: var string, row: seq[string], columnWidths: seq[int]) =
  str &= "|"

  for i, val in row:
    str &= " "

    str &= val & repeat(' ', columnWidths[i] - val.len)

    str &= " |"

  str &= "\n"

proc printTable*(headers: seq[string], values: seq[seq[string]]) =
  var str = ""

  var
    columnWidths = getColumnWidths(values, headers)
    tableWidth = headers.len + 1 + headers.len * 2

  for width in columnWidths:
    tableWidth += width

  printFillerLine(str, columnWidths)

  printLine(str, headers, columnWidths)

  printFillerLine(str, columnWidths)

  for row in  values:
    printLine(str, row, columnWidths)
    printFillerLine(str, columnWidths)

  echo str