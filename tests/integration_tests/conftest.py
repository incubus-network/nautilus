from pathlib import Path

import pytest

from .network import setup_custom_fury, setup_fury, setup_geth


@pytest.fixture(scope="session")
def fury(tmp_path_factory):
    path = tmp_path_factory.mktemp("fury")
    yield from setup_fury(path, 26650)


@pytest.fixture(scope="session")
def fury_indexer(tmp_path_factory):
    path = tmp_path_factory.mktemp("indexer")
    yield from setup_custom_fury(
        path, 26660, Path(__file__).parent / "configs/enable-indexer.jsonnet"
    )


@pytest.fixture(scope="session")
def geth(tmp_path_factory):
    path = tmp_path_factory.mktemp("geth")
    yield from setup_geth(path, 8545)


@pytest.fixture(
    scope="session", params=["fury", "geth", "fury-ws", "enable-indexer"]
)
def cluster(request, fury, fury_indexer, geth):
    """
    run on both fury and geth
    """
    provider = request.param
    if provider == "fury":
        yield fury
    elif provider == "geth":
        yield geth
    elif provider == "fury-ws":
        fury_ws = fury.copy()
        fury_ws.use_websocket()
        yield fury_ws
    elif provider == "enable-indexer":
        yield fury_indexer
    else:
        raise NotImplementedError
