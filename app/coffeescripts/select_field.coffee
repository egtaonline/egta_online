select_update = (select_id, controller_function) ->
    selected = $('select'+select_id+' :selected').val
    jQuery.post(controller_function, selected: selected)