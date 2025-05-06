import os
import requests
import time
from flaky import flaky

API_URL = os.environ["API_URL"]
TIMEOUT = 3

EXPECTED_HEADER_MAP = {
    "Access-Control-Allow-Methods": "OPTIONS,GET",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Origin":  "*",
}

print(f"Running tests against '{API_URL}'")


def delay_rerun(*args):
    time.sleep(1)
    return True


def make_api_call() -> requests.Response:
    return requests.get(API_URL, timeout=3)


def test_api_call_returns_expected_json():
    r = make_api_call()

    assert len(r.json().get("link")) > 0


@flaky(max_runs=3, rerun_filter=delay_rerun)
def test_api_call_returns_expected_headers():
    r = make_api_call()

    for header, value in EXPECTED_HEADER_MAP.items():
        assert r.headers.get(header) == value


def test_retrieve_image():
    r = make_api_call()

    assert len(r.json().get("link")) > 0

    link = r.json().get("link")

    r = requests.get(link)

    assert r.status_code == 200
