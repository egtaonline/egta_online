$(document).ready(function() {

    $("#game_simulator_id").change(function() {
        var simulator = $('select#game_simulator_id :selected').val();
        jQuery.post('/games/update_parameters', {simulator_id: simulator})
    });

});