require 'server_proxy'
require 'load_data'
require 'net/ssh'
require 'net/scp'
require 'net/ssh/multi'
require 'yaml'
require 'fileutils'
require 'pbs'
require 'helper_demon'
require 'egat_interface'

SECRET_KEY = "srgegta"
FLUX_CORES = 10
DEPLOY_PATH = "/home/wellmangroup/many-agent-simulations"
ROOT_PATH = File.dirname(__FILE__) + "/../../"