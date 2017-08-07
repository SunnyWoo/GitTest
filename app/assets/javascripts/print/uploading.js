jQuery(function($) {
  $(document).on('ajax:success', '.print_item_uploading', function(e, data) {
    $this = $(e.target);
    $this.addClass('disabled');
    $this.text('Uploading...');
    
    var url = data.url;

    var poke = function() {
      $.getJSON(url, function(data) {
        if (data.status == 'Uploading') {
          setTimeout(poke, 5000);
        } else {
          $this.text('Printed!');
          setTimeout(function(){
            $this.parent().parent().remove();
          }, 1000);
        }
      });
    };

    poke();
  });

  $(document).on('ajax:before', '.print_item_uploading.disabled', function(e) {
    return false;
  });
});