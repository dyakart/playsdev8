#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer
import psutil
import json

class CPUHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        # Получаем текущую загрузку CPU (за 1 сек.)
        cpu_usage = psutil.cpu_percent(interval=1)
        data = {"cpu_usage": cpu_usage}
        response_bytes = json.dumps(data).encode("utf-8")

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(response_bytes)))
        self.end_headers()
        self.wfile.write(response_bytes)

def run(server_class=HTTPServer, handler_class=CPUHandler, port=9000):
    server_address = ('', port)
    print(f"Запуск CPU сервера на порту {port}")
    httpd = server_class(server_address, handler_class)
    httpd.serve_forever()

if __name__ == '__main__':
    run()
