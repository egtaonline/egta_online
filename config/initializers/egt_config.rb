require 'server_proxy'
require 'net/ssh'
require 'net/scp'
require 'yaml'
require 'fileutils'
require 'pbs'
require 'helper_demon'
require 'transformation'

FLUX_CORES = 10
DEPLOY_PATH = "/home/wellmangroup/many-agent-simulations"