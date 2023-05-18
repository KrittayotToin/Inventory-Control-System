//= require rails-ujs
//= require toastr
//= require activestorage
//= require turbolinks
//= require_tree .



$(document).ready(function () {
  $.ajax({
    url: '/equipment_names',
    success: function (data) {
      $('#equipment-search').typeahead({
        source: data
      });
    }
  });
});

//get members
$.ajax({
  url: '/members/all',
  method: 'GET',
  success: function (response) {
    console.log(response);
  },
  error: function (xhr, status, error) {
    console.error('Request failed:', error);
  }
});




//post members num
const data = [1, 2, 3, 4, 5];

$.ajax({
  url: '/members/num',
  method: 'POST',
  data: JSON.stringify(data), // Convert data array to JSON string
  contentType: 'application/json', // Set content type to JSON
  success: function (response) {
    console.log(response);
  },
  error: function (xhr, status, error) {
    console.error('Request failed:', error);
  }
});
