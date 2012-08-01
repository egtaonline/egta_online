require 'spec_helper'

describe ObservationProcessor do
  describe 'process_file' do
    let(:features){ double('features') }
    let(:profile){ double(assignment: 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2', features_observations: features) }
    
    context 'valid file' do
      let(:simulation){ double(profile: profile, number: 3, files: []) }
      let(:json){ Oj.load_file("#{Rails.root}/db/3/observation1.json") }
      
      before do
        json['players'].each{ |player| profile.should_receive(:create_player).with(player['role'], player['strategy'], player['payoff'], player['features']) }
        json['features'].each{ |key, value| features.should_receive(:create).with(name: key, observation: value) }
        profile.should_receive(:inc).with(:sample_count, 1)
        simulation.should_receive(:push).with(:files, "observation1.json")
      end
      
      it{ ObservationProcessor.process_file("#{Rails.root}/db/3/observation1.json", simulation) }
    end
    
    context 'previously seen file' do
      let(:simulation){ double(profile: profile, number: 3, files: ['observation1.json']) }
      
      it{ ObservationProcessor.process_file("#{Rails.root}/db/3/observation1.json", simulation) }
    end
    
    context 'invalid file' do
      let(:simulation){ double(profile: profile, number: 3, files: [], error_message: "") }
      
      before do
        ObservationValidator.should_receive(:validate).with("#{Rails.root}/db/3/observation1.json", 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2').and_return(nil)
        simulation.should_receive(:update_attribute).with(:error_message, "#{Rails.root}/db/3/observation1.json was malformed or didn't match the expected profile assignment.\n")
      end
      
      it{ ObservationProcessor.process_file("#{Rails.root}/db/3/observation1.json", simulation) }
    end
  end
end