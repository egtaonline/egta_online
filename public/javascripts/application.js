// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
jQuery(function($) {
  // when the #simulator_id field changes
  $("#game_simulator_id").change(function() {
    // make a POST call and replace the content
    var simulator = $('select#game_simulator_id :selected').val();
    jQuery.post('/analysis/games/update_parameters', {simulator_id: simulator})
  });
  $("#source_val_0").click(function() {
    jQuery.post(location.pathname.replace("new","")+"update_choice", {source: 0})
  });

  $("#source_val_1").click(function() {
    jQuery.post(location.pathname.replace("new","")+"update_choice", {source: 1})
  });

})
