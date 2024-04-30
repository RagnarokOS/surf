#!/usr/bin/python3

import signal
import subprocess
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, HTTPServer

requested_file = ""
surf_proc = None

class HTTPHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        global requested_file
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write("hello world".encode('utf-8'))
        requested_file = self.path

def alarm_handler(signum, frame):
    raise TimeoutError

def serve_files():
    httpd = HTTPServer(('', 8000), HTTPHandler)
    httpd.handle_request()

def surf_request_file(filename):
    global surf_proc
    # wait a bit for server to be ready
    time.sleep(1)
    if not surf_proc:
        surf_proc = subprocess.Popen(["/usr/bin/surf", "http://localhost:8000" + filename])
    else:
        # focus surf window
        subprocess.run(["xdotool", "search", "--onlyvisible", "--class", "Surf", "windowfocus"])
        # send Ctrl+g, wait 900ms, send URL + Return
        # (xvkbd is used as xdotool sends keys with wrong layout)
        subprocess.run(["xvkbd", "-window", "Surf", "-text", "\\Cg\\D9http://localhost:8000" + filename + "\\r"])

def surf_reload():
    # wait a bit for server to be ready
    time.sleep(1)
    subprocess.run(["xdotool", "search", "--onlyvisible", "--class", "Surf", "windowfocus"])
    subprocess.run(["xvkbd", "-window", "Surf", "-text", "\\Cr"])

def shutdown(status):
    if surf_proc:
        surf_proc.terminate()
    sys.exit(status)

def expect_request_file(filename):
    global requested_file
    signal.alarm(5)
    requested_file = ""
    try:
        serve_files()
    except TimeoutError:
        print("FAIL: Timeout has been reached while waiting for request of: ", filename)
        shutdown(1)
    signal.alarm(0)
    if requested_file != filename:
        print("FAIL: Requested '" + requested_file + "' instead of '" + filename + "'")
        shutdown(1)

# Test 1:
# start surf and request a file via command line
threading.Thread(target=surf_request_file, args=("/index1.html",)).start()
expect_request_file("/index1.html")

# Test 2:
# request another URL from running instance via keyboard shortcut
threading.Thread(target=surf_request_file, args=("/index2.html",)).start()
expect_request_file("/index2.html")

# Test 3:
# use reload command to request current page again
threading.Thread(target=surf_reload).start()
expect_request_file("/index2.html")

print("OK: Tests passed.")

shutdown(0)
