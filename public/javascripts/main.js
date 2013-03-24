$(function(){
  $('#get_words').click(function(){
    var url = $('#url').val();
    $.get('/words?url='+url, function(data){
      $('#result').html(data.split("\n").join("<br/>"));
    })
  })
})
