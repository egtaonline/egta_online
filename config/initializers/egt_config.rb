require 'server_proxy'
require 'data_parser'
require 'sequence'
require 'net/ssh'
require 'net/scp'
require 'net/ssh/multi'
require 'yaml'
require 'fileutils'
require 'pbs'
require 'helper_demon'
require 'egat_interface'
require 'strategy_manipulation'

SECRET_KEY = "srgegta"
FLUX_CORES = 10
ROOT_PATH = File.dirname(__FILE__) + "/../../"