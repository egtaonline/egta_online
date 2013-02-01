require 'spec_helper'

describe PbsWrapper do
  describe 'create_wrapper' do
    let(:scheduler){ double(simulator: double(name: 'fake', fullname: 'fake-totally', email: "test@test.com"), process_memory: 1000, time_per_sample: 300) }

    context 'flux' do
      let(:simulation){ double(flux: true, scheduler: scheduler, scheduler_nodes: 1, _id: 3, id: 3, size: 30) }
      let(:src_dir){ 'tmp/simulations' }

      before do
        simulation.stub(:[]).with('flux').and_return(true)
        document = <<HEREDOC
#!/bin/bash
#PBS -S /bin/sh
#PBS -A wellman_flux
#PBS -q flux
#PBS -l nodes=1,pmem=1000mb,walltime=02:30:00,qos=flux
#PBS -N egta-fake
#PBS -W umask=0007
#PBS -W group_list=wellman
#PBS -o #{Yetting.simulations_path}/3/out
#PBS -e #{Yetting.simulations_path}/3/error
#PBS -M test@test.com
umask 0007
mkdir /tmp/${PBS_JOBID}
cp -r #{Yetting.deploy_path}/fake-totally/fake/* /tmp/${PBS_JOBID}
cp -r #{Yetting.simulations_path}/3 /tmp/${PBS_JOBID}
cd /tmp/${PBS_JOBID}
script/batch 3 30
cp -r /tmp/${PBS_JOBID}/3 #{Yetting.simulations_path}
rm -rf /tmp/${PBS_JOBID}
HEREDOC
        f = double("file")
        f.should_receive(:write).with(document)
        File.should_receive(:open).with("#{src_dir}/#{simulation.id}/wrapper", 'w').and_yield(f)
      end

      it{ PbsWrapper.create_wrapper(simulation, src_dir) }
    end

    context 'cac' do
      let(:simulation){ double(flux: false, scheduler: scheduler, scheduler_nodes: 1, _id: 3, id: 3, size: 30) }
      let(:src_dir){ 'tmp/simulations' }

      before do
        simulation.stub(:[]).with('flux').and_return(false)
        document = <<HEREDOC
#!/bin/bash
#PBS -S /bin/sh
#PBS -A cac
#PBS -q cac
#PBS -l nodes=1,pmem=1000mb,walltime=02:30:00,qos=cac
#PBS -N egta-fake
#PBS -W umask=0007
#PBS -W group_list=wellman
#PBS -o #{Yetting.simulations_path}/3/out
#PBS -e #{Yetting.simulations_path}/3/error
#PBS -M test@test.com
umask 0007
mkdir /tmp/${PBS_JOBID}
cp -r #{Yetting.deploy_path}/fake-totally/fake/* /tmp/${PBS_JOBID}
cp -r #{Yetting.simulations_path}/3 /tmp/${PBS_JOBID}
cd /tmp/${PBS_JOBID}
script/batch 3 30
cp -r /tmp/${PBS_JOBID}/3 #{Yetting.simulations_path}
rm -rf /tmp/${PBS_JOBID}
HEREDOC
        f = double("file")
        f.should_receive(:write).with(document)
        File.should_receive(:open).with("#{src_dir}/#{simulation.id}/wrapper", 'w').and_yield(f)
      end

      it{ PbsWrapper.create_wrapper(simulation, src_dir) }
    end

    context 'multi-node' do
      let(:simulation){ double(flux: false, scheduler: scheduler, scheduler_nodes: 2, _id: 3, id: 3, size: 30) }
      let(:src_dir){ 'tmp/simulations' }

      before do
        simulation.stub(:[]).with('flux').and_return(false)
        document = <<HEREDOC
#!/bin/bash
#PBS -S /bin/sh
#PBS -A cac
#PBS -q cac
#PBS -l nodes=2,pmem=1000mb,walltime=02:30:00,qos=cac
#PBS -N egta-fake
#PBS -W umask=0007
#PBS -W group_list=wellman
#PBS -o #{Yetting.simulations_path}/3/out
#PBS -e #{Yetting.simulations_path}/3/error
#PBS -M test@test.com
umask 0007
mkdir /tmp/${PBS_JOBID}
cp -r #{Yetting.deploy_path}/fake-totally/fake/* /tmp/${PBS_JOBID}
cp -r #{Yetting.simulations_path}/3 /tmp/${PBS_JOBID}
cd /tmp/${PBS_JOBID}
script/batch 3 30 ${PBS_NODEFILE}
cp -r /tmp/${PBS_JOBID}/3 #{Yetting.simulations_path}
rm -rf /tmp/${PBS_JOBID}
HEREDOC
        f = double("file")
        f.should_receive(:write).with(document)
        File.should_receive(:open).with("#{src_dir}/#{simulation.id}/wrapper", 'w').and_yield(f)
      end

      it{ PbsWrapper.create_wrapper(simulation, src_dir) }
    end
  end
end