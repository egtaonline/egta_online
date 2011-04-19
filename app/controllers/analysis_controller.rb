#Authenticates users
class AnalysisController < ApplicationController
  before_filter :authenticate_user!
end
