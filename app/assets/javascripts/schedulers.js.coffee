jQuery ->
  $("#scheduler_simulator_id").change ->
    Simulator = $('select#scheduler_simulator_id :selected').val()
    jQuery.post '/schedulers/update_parameters', {simulator_id: Simulator}