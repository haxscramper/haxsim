import std/[asynchttpserver, asyncdispatch, os]

proc handler(req: Request) {.async.} =
  echo "request for path ", req.url.path
  let cwd = getCurrentDir()
  let file = cwd / req.url.path
  if fileExists(file):
    await req.respond(Http200, file.readFile())
  else:
    await req.respond(Http404, "Not Found " & file)

# Open `http://0.0.0.0:8080/main.html`
var server = newAsyncHttpServer()
waitFor server.serve(Port(8080), handler)
