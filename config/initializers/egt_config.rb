require "sequence"
require "nyx_wrapper"
require "submission"
require "data_parser"

FLUX_LIMIT = 30
WELLMAN = 141825
KEY = 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAqrTdv0q8SKL0tWXEYMu6GrNG+FZX4a7gpc6NNvk7Zdwn2Vjl+he20lHJ96Tkj3NNGBDLNiq7ULyVL0gHgh6fKw41QMW/Wn4osWnaMBtsuQ/sy0QfLAWE42x7AM7sXtn9asRJCzRB9XPPMyZeNwakQ4ckv7LLs41LpWHm9VFONEpqp17U2A8L/KoHyPsAUf/Y0tJ3sIUrHq5fMfwU7OMNvPf2OSr5j0sMbPMlr/ot8xu3UCZOurefER5dFE0YEDfSD5wnIBMoCw1blHFYnZ1gfbLpxMt+jUAdD2qY+sCmU6gfiIag2behKPJcPDuswLiy76UjA9kfNu2arnkYNFwlEw== deployment@egtaonline'

module InheritedResources
  module BaseHelpers
    def collection
      get_collection_ivar || set_collection_ivar(end_of_association_chain.page params[:page])
    end
  end
end