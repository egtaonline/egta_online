$(document).ready(function() {

    $("#sim_simulator_id").change(function() {
        var simulator = $('select#sim_simulator_id :selected').val();
        jQuery.post('/games/update_parameters', {simulator_id: simulator})
    });

    $("#simulation_game_id").change(function() {
        var game = $('select#simulation_game_id :selected').val();
        jQuery.get('/simulations/update_game', {game_id: game})
    });

    $("#simulator_id").change(function() {
        var simulator = $('select#simulator_id :selected').val();
        jQuery.post(location.pathname+'/select_simulator', {simulator_id: simulator})
    });

});