require 'server_proxy'
require 'net/ssh'
require 'net/scp'
require 'net/ssh/multi'
require 'yaml'
require 'fileutils'
require 'pbs'
require 'helper_demon'
require 'transformation'

SECRET_KEY = "srgegta"
FLUX_CORES = 10
DEPLOY_PATH = "/home/wellmangroup/many-agent-simulations"
ROOT_PATH = File.dirname(__FILE__) + "/../../"