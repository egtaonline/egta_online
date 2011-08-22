require "strategy_manipulation"
require "sequence"
require "server_proxy"
require "submission"
require "data_parser"

SECRET_KEY = "srgegta"
FLUX_LIMIT = 30
NYX_PROXY = ServerProxy.new
NYX_PROXY.start