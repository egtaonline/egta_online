# encoding: utf-8

class SimulatorUploader < CarrierWave::Uploader::Base

  # Choose what kind of storage to use for this uploader:
  storage :file

  def extension_white_list
     %w(zip)
  end

end
