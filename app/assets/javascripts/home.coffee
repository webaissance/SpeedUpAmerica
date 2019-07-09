has_successful_location = false

bind_rating_stars = ->
  star_options =
    stars: 7
    min: 0
    max: 7
    step: 1
    displayOnly: false
    showClear: false
    showCaption: false
    size:'sm'

  $('.rating-container input').each ->
    $(this).rating star_options

disable_form_inputs = ->
  $('#form-container .form-fields input').prop('disabled', true)

set_coords = (position) ->
  $('#submission_latitude').attr 'value', position.coords.latitude
  $('#submission_longitude').attr 'value', position.coords.longitude
  $.ajax
      url: 'home/get_location_data'
      type: 'POST'
      dataType: 'json'
      data:
        latitude: position.coords.latitude
        longitude: position.coords.longitude
      success: (data) ->
        has_successful_location = true
        $("input[name='submission[address]']").attr 'value', data['address']
        $("input[name='submission[zip_code]']").attr 'value', data['zip_code']
        $('.test-speed-btn').prop('disabled', false)
        $('.location-warning').addClass('hide')
        $('#location_next_button').attr('disabled', false)

      error: (request, statusText, errorText) ->
        err = new Error("get location data failed")

        Sentry.setExtra("status_code", request.status)
        Sentry.setExtra("body",  request.responseText)
        Sentry.setExtra("response_status",  statusText)
        Sentry.setExtra("response_error",  errorText)
        Sentry.captureException(err)

set_coords_by_latlng = (latlng) ->
  $('submission_latitude').attr 'value', latlng.lat
  $('submission_latitude').attr 'value', latlng.lng
  $.ajax
    url: 'home/get_location_data'
    type: 'POST'
    dataType: 'json'
    data:
      latitude: latlng.lat
      longitude: latlng.lng
    success: (data) ->
        has_successful_location = true
        $("input[name='submission[address]']").attr 'value', data['address']
        $("input[name='submission[zip_code]']").attr 'value', data['zip_code']
        $('#location_next_button').attr('disabled', false)

      error: (request, statusText, errorText) ->
        err = new Error("get location data failed")
        Sentry.setExtra("status_code", request.status)
        Sentry.setExtra("body",  request.responseText)
        Sentry.setExtra("response_status",  statusText)
        Sentry.setExtra("response_error",  errorText)
        Sentry.captureException(err)

block_callback = (err) ->
  $('#error-geolocation').modal('show')

  Sentry.setExtra("error_code", err.code)
  Sentry.setExtra("error_message", err.message)
  Sentry.captureException(err)

get_location = ->
  if navigator.geolocation
    navigator.geolocation.getCurrentPosition set_coords, block_callback

check_fields_validity = ->
  is_valid = true

  unless $('#submission_monthly_price')[0].checkValidity()
    $('#submission_monthly_price').addClass('got-error')
    $('#price_error_span').removeClass('hide')
    is_valid = false
  else
    $('#submission_monthly_price').removeClass('got-error')
    $('#price_error_span').addClass('hide')

  unless $('#submission_provider_down_speed')[0].checkValidity()
    $('#submission_provider_down_speed').addClass('got-error')
    $('#speed_error_span').removeClass('hide')
    is_valid = false
  else
    $('#submission_provider_down_speed').removeClass('got-error')
    $('#speed_error_span').addClass('hide')

  is_valid

is_mobile_data = ->
  $(".checkboxes-container input[name='submission[testing_for]']:checked").val() == 'Mobile Data'

enable_speed_test = ->
  $('.test-speed-btn').on 'click', ->
    if check_fields_validity()
      $('#testing_speed').modal('show');

      setTimeout (->
        $('#start_ndt_test').click()
      ), 200

numeric_field_constraint = ->
  $('.numeric').keydown (e) ->
    if $.inArray(e.keyCode, [
        46
        8
        9
        27
        13
        110
        190
      ]) != -1 or e.keyCode == 65 and (e.ctrlKey == true or e.metaKey == true) or e.keyCode >= 35 and e.keyCode <= 40
      return
    if (e.shiftKey or e.keyCode < 48 or e.keyCode > 57) and (e.keyCode < 96 or e.keyCode > 105)
      e.preventDefault()

set_error_for_invalid_fields = ->
  $('#submission_monthly_price').focusout ->
    unless $('#submission_monthly_price')[0].checkValidity()
      $('#submission_monthly_price').addClass('got-error')
      $('#price_error_span').removeClass('hide')
    else
      $('#submission_monthly_price').removeClass('got-error')
      $('#price_error_span').addClass('hide')

  $('#submission_provider_down_speed').focusout ->
    unless $('#submission_provider_down_speed')[0].checkValidity()
      $('#submission_provider_down_speed').addClass('got-error')
      $('#speed_error_span').removeClass('hide')
      is_valid = false
    else
      $('#submission_provider_down_speed').removeClass('got-error')
      $('#speed_error_span').addClass('hide')

places_autocomplete = ->
  placesAutocomplete = places({
    application_id: 'pl1SUFESCKRV',
    api_key: '6039fe8e924c5e9f9a2edd9cecba075c',
    container: window.document.querySelector('#address-input')
  });

  placesAutocomplete.on 'change', (eventResult) -> 
    if eventResult
      latlng = eventResult.suggestion.latlng
      set_coords_by_latlng latlng
      $('#location_next_button').attr('disabled', false)

  placesAutocomplete

$ ->
  bind_rating_stars()
  disable_form_inputs()
  numeric_field_constraint()
  
  if window.location.pathname == '/'
    enable_speed_test()
    set_error_for_invalid_fields()

  placesAutocomplete = places({
    application_id: 'pl1SUFESCKRV',
    api_key: '6039fe8e924c5e9f9a2edd9cecba075c',
    container: window.document.querySelector('#address-input')
  });

  placesAutocomplete.on 'change', (eventResult) -> 
    if eventResult
      latlng = eventResult.suggestion.latlng
      set_coords_by_latlng latlng
      $('#location_next_button').attr('disabled', false)

  $('[rel="tooltip"]').tooltip({'placement': 'top'});
  $('#testing_for_button').attr('disabled', true)
  $('.test-speed-btn').attr('disabled', true)
  $(".checkboxes-container input[name='submission[testing_for]']").prop('checked', false)

  $('#take_test').on 'click', ->
    $('.title-container').addClass('hidden');
    $('#form-container').removeClass('hide')
    $('#form-step-0 input').prop('disabled', false)
    $('#introduction').addClass('hide')
    $('.home-wrapper').addClass('mobile-wrapper-margin')

    $(".checkboxes-container input[name='submission[location]']").on 'change', ->
      $('#location_button').prop('disabled', false)
      $(".checkboxes-container input[name='submission[location]']").each ->
        $(this).prop('checked', false)
      $(this).prop('checked', true)

      if $('#location_geolocation').prop('checked')
        $('#location_button').removeClass('hide')
        $('#location-address-input').addClass('hide')
        get_location()

      if $('#location_address').prop('checked')
        $('#location_button').addClass('hide')
        $('#location-address-input').removeClass('hide')

      if $('#location_disable').prop('checked')
        $('#location_button').addClass('hide')
        $('#location-address-input').addClass('hide')
        $('#location_next_button').attr('disabled', false)

  $('#location_button').on 'click', ->
    get_location()

  $('#location_next_button').on 'click', ->
    if $('#location_disable').prop('checked')
      $('#form-step-0').addClass('hide')

      $('#testing_speed').modal('show');

      setTimeout (->
        $('#start_ndt_test').click()
      ), 200
    else
      $('#form-step-0').addClass('hide')
      $('#form-step-1').removeClass('hide')
      $('#form-step-1 input').prop('disabled', false)
      $('.test-speed-btn').prop('disabled', false)
      $('.location-warning').addClass('hide')



  $(".checkboxes-container input[name='submission[testing_for]']").on 'change', ->
    $(".checkboxes-container input[name='submission[testing_for]']").each ->
      $(this).prop('checked', false)
    $(this).prop('checked', true)
    $('#testing_for_button').attr('disabled', !$(".checkboxes-container input[name='submission[testing_for]']").is(':checked'));

  $('#testing_for_button').on 'click', ->
    testing_for = $(".checkboxes-container input[name='submission[testing_for]']:checked").data('target')
    $(testing_for).removeClass('hide')
    $(testing_for + ' input').prop('disabled', false)
    $(testing_for + ' select').prop('disabled', false)
    $('#form-step-1').addClass('hide')

