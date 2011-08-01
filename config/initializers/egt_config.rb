require "strategy_manipulation"
require "sequence"
require "server_proxy"
require "pbs"
require "data_parser"

SECRET_KEY = "srgegta"
FLUX_CORES = 20
NYX_PROXY = ServerProxy.new
NYX_PROXY.start