require "sequence"
require "nyx_wrapper"
require "submission"
require "data_parser"
require 'assignment_sorting'

FLUX_LIMIT = 120
WELLMAN = 141825
KEY = 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAqrTdv0q8SKL0tWXEYMu6GrNG+FZX4a7gpc6NNvk7Zdwn2Vjl+he20lHJ96Tkj3NNGBDLNiq7ULyVL0gHgh6fKw41QMW/Wn4osWnaMBtsuQ/sy0QfLAWE42x7AM7sXtn9asRJCzRB9XPPMyZeNwakQ4ckv7LLs41LpWHm9VFONEpqp17U2A8L/KoHyPsAUf/Y0tJ3sIUrHq5fMfwU7OMNvPf2OSr5j0sMbPMlr/ot8xu3UCZOurefER5dFE0YEDfSD5wnIBMoCw1blHFYnZ1gfbLpxMt+jUAdD2qY+sCmU6gfiIag2behKPJcPDuswLiy76UjA9kfNu2arnkYNFwlEw== deployment@egtaonline'

class Object
  def deep_copy
    Marshal.load(Marshal.dump(self))
  end
end