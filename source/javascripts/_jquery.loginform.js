$(document).ready(function() {
  $('.moresearch').toggle(function(){
    $('a',(this)).text("- Rút gọn tiêu chí tìm kiếm").addClass('showless');
    $('#right-more').show();
    $('#right-more').animate({ 'height': $('#right-more').data('maxheight') });
  }, function(){
    $('a',(this)).text("+ Mở rông tiêu chí tìm kiếm").removeClass('showless');
    $('#right-more').hide();
    $('#right-more').animate({ 'height': $('#right-more').data('height') });
  });
  $('.buttonthongtinlienhe a').click(function(){
    $('.thongtinlienhe').show();
    $('.buttonthongtinlienhe').hide();
  })
  $('.morongtimkiem').toggle(function(){
    $(this).text("- Rút gọn tiêu chí tìm việc làm tuyển dụng").addClass('showless');
    $('#search-more').show();
    $('#search-more').animate({ 'height': $('#search-more').data('maxheight') });
  }, function(){
    $(this).text("+ Mở rông tiêu chí tìm việc làm tuyển dụng").removeClass('showless');
    $('#search-more').hide();
    $('#search-more').animate({ 'height': $('#search-more').data('height') });
  });
  $(".multi-checklist").multiDrop();
  $('.multiselect').multiselect2side({
    selectedPosition: 'right',
    moveOptions: false,
    labelsx: '',
    labeldx: '',
    autoSort: false,
    autoSortAvailable: true
  });


  $('a.login-window').click(function() {

    //Getting the variable's value from a link 
    var loginBox = $(this).attr('href');

    //Fade in the Popup
    $(loginBox).fadeIn(300);

    //Set the center alignment padding + border see css style
    var popMargTop = ($(loginBox).height() + 24) / 2; 
    var popMargLeft = ($(loginBox).width() + 24) / 2; 

    $(loginBox).css({ 
      'margin-top' : -popMargTop,
      'margin-left' : -popMargLeft
    });

    // Add the mask to body
    $('body').append('<div id="mask"></div>');
    $('#mask').fadeIn(300);

    return false;
  });

  // When clicking on the button close or the mask layer the popup closed
  $('a.close, #mask').live('click', function() { 
    $('#mask , .login-popup').fadeOut(300 , function() {
      $('#mask').remove();  
    }); 
    return false;
  });
});
function changeSalary(target){
  var Salary = target.value.toLowerCase();
  switch(Salary)
  {
    case "normal":
      document.getElementById("divSalaryFrom").style.display = "";
    document.getElementById("divSalaryTo").style.display = "";
    break;
    case "morethan":
      document.getElementById("divSalaryFrom").style.display = "";
    document.getElementById("divSalaryTo").style.display = "none";
    break;
    case "negotiable":
      document.getElementById("divSalaryFrom").style.display = "none";
    document.getElementById("divSalaryTo").style.display = "none";
    break;
    case "competitive":
      document.getElementById("divSalaryFrom").style.display = "none";
    document.getElementById("divSalaryTo").style.display = "none";
    break;
  }
}
function changeMoney(target){
  $('.moneyrate').val($(target).val());
} 


