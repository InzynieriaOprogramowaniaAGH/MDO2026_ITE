from http.server import BaseHTTPRequestHandler, HTTPServer

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <title>Sprawozdanie 12</title>
        </head>
        <body>
            <h1>Kontener dziala w Azure</h1>
            <p>Aplikacja Python HTTP zostala uruchomiona z obrazu Docker Hub.</p>
            <p>Sprawozdanie 12 - Azure Container Instance</p>
        </body>
        </html>
        """
        self.send_response(200)
        self.send_header("Content-type", "text/html; charset=utf-8")
        self.end_headers()
        self.wfile.write(html.encode("utf-8"))

server = HTTPServer(("0.0.0.0", 8000), Handler)
print("Serwer dziala na porcie 8000")
server.serve_forever()

