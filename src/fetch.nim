# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import std/[httpclient, net, base64, uri, strformat]
import argparse


proc fetchUrl(url: string, insecure: bool = false): string =

  var verifyMode = (if insecure: CVerifyNone else: CVerifyPeerUseEnvVars)
  var client = newHttpClient(sslContext=newContext(verifyMode=verifyMode))
  var uri_p = parseUri(url)

  if uri_p.username != "" and uri_p.password != "":
    client.headers["Authorization"] = "Basic " & base64.encode(decodeUrl(uri_p.username) & ":" & uri_p.password)

  result = client.getContent(fmt"{uri_p.scheme}://{uri_p.hostname}{uri_p.path}?{uri_p.query}")


proc cli() =
  var parser = newParser:
      help("Fetches a http/https url")
      flag("-k", "--insecure",
              help = "Allow insecure server connections when using SSL")
      arg("url", nargs = 1, help = "The API endpoint for Gitlab. Defaults to the origin")
      run:
          echo fetchUrl(opts.url, opts.insecure)

  try:
      parser.run(commandLineParams())

  except ShortCircuit as e:
      if e.flag == "argparse_help":
          echo parser.help
          quit(0)
  except UsageError:
      echo parser.help
      stderr.writeLine getCurrentExceptionMsg()
      quit(1)
  except:
      stderr.writeLine getCurrentExceptionMsg()
      quit(1)


when isMainModule:
  cli()
