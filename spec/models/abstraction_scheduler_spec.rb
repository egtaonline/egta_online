require 'spec_helper'

describe AbstractionScheduler do
  describe 'fill_role' do
    it { AbstractionScheduler.fill_role({ "a" => 3, "b" => 2, "c" => 1 }, 12).should eql({"a" => 6, "b" => 4, "c" => 2}) }
    it { AbstractionScheduler.fill_role({ "a" => 3, "b" => 3 }, 7).should eql({"a" => 4, "b" => 3}) }
    it { AbstractionScheduler.fill_role({ "a" => 3, "b" => 2, "c" => 1 }, 14).should eql({"a" => 7, "b" => 5, "c" => 2}) }
  end

  describe '#reduced_game' do
    let(:scheduler){ Fabricate(:dpr_game_scheduler, size: 4) }

    context 'single role' do
      before do
        scheduler.add_role('All', 4, 2)
        scheduler.add_strategy('All', 'A')
        scheduler.add_strategy('All', 'B')
      end

      it { scheduler.reduced_game.should eql([{ 'All' => { 'A' => 2 } }, { 'All' => { 'A' => 1, 'B' => 1 } }, { 'All' => { 'B' => 2 } }]) }
    end

    context 'multiple roles' do
      before do
        scheduler.add_role('Buyer', 2, 1)
        scheduler.add_role('Seller', 2, 1)
        scheduler.add_strategy('Buyer', 'A')
        scheduler.add_strategy('Buyer', 'B')
        scheduler.add_strategy('Seller', 'C')
        scheduler.add_strategy('Seller', 'D')
      end

      it { scheduler.reduced_game.should eql([{ 'Buyer' => { 'A' => 1 }, 'Seller' => { 'C' => 1 } }, { 'Buyer' => { 'A' => 1 }, 'Seller' => { 'D' => 1 } },
                                              { 'Buyer' => { 'B' => 1 }, 'Seller' => { 'C' => 1 } }, { 'Buyer' => { 'B' => 1 }, 'Seller' => { 'D' => 1 } }]) }
    end
  end
end