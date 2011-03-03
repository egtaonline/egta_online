/* DO NOT MODIFY. This file was compiled Sat, 26 Feb 2011 21:59:23 GMT from
 * /Users/bcassell/Ruby/egt_working_directory/egt_mongoid/app/coffeescripts/select_field.coffee
 */

(function() {
  var select_update;
  select_update = function(select_id, controller_function) {
    var selected;
    selected = $('select' + select_id + ' :selected').val;
    return jQuery.post(controller_function, {
      selected: selected
    });
  };
}).call(this);
