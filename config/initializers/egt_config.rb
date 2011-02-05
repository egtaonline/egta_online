#require 'server_proxy'
require 'net/ssh'
require 'net/scp'
require 'yaml'
require 'fileutils'
#require 'pbs'

FLUX_CORES = 10
DEPLOY_PATH = "/home/wellmangroup/many-agent-simulations"