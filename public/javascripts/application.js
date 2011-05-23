$(document).ready(function() {

    $("#simulation_game_id").change(function() {
        var game = $('select#simulation_game_id :selected').val();
        jQuery.get('/simulations/update_game', {game_id: game})
    });

    $("#symmetric_game_simulator").change(function() {
        var simulator = $('select#symmetric_game_simulator :selected').val();
        jQuery.post(location.pathname+'/update_parameters', {object_class: 'simulator', object_id: simulator})
    });

});