require 'server_proxy'
require 'sequence'
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
ROOT_PATH = File.dirname(__FILE__) + "/../../"