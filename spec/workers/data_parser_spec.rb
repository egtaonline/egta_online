require 'spec_helper'

describe DataParser do
  ### Integration test, consider pulling to cucumber and writing unit tests
  describe 'perform' do
    let(:simulation){ double('simulation') }
    let(:simulations){ [simulation] }
    
    context 'multiple valid observations' do
      before do
        Simulation.stub(:where).with({ number: 3 }).and_return(simulations)
        ObservationProcessor.stub(:process_file) do | file, sim |
          simulation.stub(:files).and_return(['observation1.json','observation2.json'])
        end
      end
      
      it 'completes successfully' do
        simulation.should_receive(:finish!)
        DataParser.perform(3, "#{Rails.root}/db/3")
      end
    end
    
    context 'some failures' do
      before do
        Simulation.stub(:where).with({ number: 4 }).and_return(simulations)
        ObservationProcessor.stub(:process_file) do | file, sim |
          simulation.stub(:files).and_return(['string_observation.json'])
        end
      end
      
      it 'does a reasonable job with partial completeness' do
        simulation.should_receive(:finish!)
        DataParser.perform(4, "#{Rails.root}/db/4")
      end
    end
    
    context 'all failures' do
      before do
        Simulation.stub(:where).with({ number: 5 }).and_return(simulations)
        ObservationProcessor.stub(:process_file) do | file, sim |
          simulation.stub(:files).and_return([])
        end
      end
      
      it 'fails the simulation if there are no valid files' do
        simulation.should_receive(:failure!)
        DataParser.perform(5, "#{Rails.root}/db/5")
      end
    end
  end
end