$ ->
  $("#selector_simulator_id").change ->
    Simulator = $('select#selector_simulator_id :selected').val()
    jQuery.post 'update_parameters', {simulator_id: Simulator}