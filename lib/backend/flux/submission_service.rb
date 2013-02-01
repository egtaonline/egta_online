class SubmissionService
  def initialize(login_connection)
    @login_connection = login_connection
  end

  def submit(simulation)
    begin
      job_return = @login_connection.exec!("qsub -V -r n #{Yetting.simulations_path}/#{simulation.id}/wrapper")
      if job_return != nil
        job_return = job_return.split(".").first
        if job_return =~ /\A\d+\z/
          simulation.queue_as job_return.to_i
        else
          simulation.fail "submission failed: #{job_return}"
        end
      else
        simulation.fail "unknown submission failure"
      end
    rescue Exception => e
      simulation.fail "failed in the submission step: #{e}"
    end
  end
end
