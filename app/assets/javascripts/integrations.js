(function() {
  // Adding a trailing space for ease of combining with other selectors.
  var topSelector = '#new-integration ';
  var Finalization = finalizationFactory('finalize-integration');
  var RecipientListChoice = filteredChoiceFactory({
    id: 'choice-recipient-list',
    configuredServiceId: function() {
      return GmailAccountChoice.val();
    },
    nextElement: Finalization
  });
  var GmailAccountChoice = choiceFactory({
    id: 'choice-gmail-account',
    type: 'radio',
    nextElement: RecipientListChoice
  });
  var DataDestinationChoices = choiceListFactory({
    id: 'choices-data-destination',
    choices: [GmailAccountChoice, RecipientListChoice],
    nextElement: Finalization
  });
  var MessageChoice = choiceFactory({
    id: 'choice-message',
    nextElement: DataDestinationChoices,
    hidden: true
  });
  var PatternChoice = choiceFactory({
    id: 'choice-pattern',
    nextElement: MessageChoice
  });
  var AlertChoices = choiceListFactory({
    id: 'choices-alert',
    choices: [PatternChoice, MessageChoice],
    nextElement: DataDestinationChoices
  });
  var FormChoice = filteredChoiceFactory({
    id: 'choice-form',
    configuredServiceId: function() {
      return ServerChoice.val();
    },
    nextElement: AlertChoices
  });
  var ServerChoice = choiceFactory({
    id: 'choice-server',
    type: 'radio',
    nextElement: FormChoice
  });
  var ODKChoices = choiceListFactory({
    id: 'choices-odk',
    choices: [ServerChoice, FormChoice],
    nextElement: AlertChoices
  });
  var DataSourceServiceChoice = serviceChoiceFactory({
    serviceIds: ['service-odk', 'service-dhis2'],
    nextElement: ODKChoices
  });
  var DataSourceChoices = listenerFactory([
    DataSourceServiceChoice,
    ODKChoices
  ]);
  var CongenialEnigma = listenerFactory([
    DataSourceChoices,
    AlertChoices,
    DataDestinationChoices
  ]);
  CongenialEnigma.listen();
  return;


  /* ------------------------------------------------------------------------ */
                    /* UI helper functions */
  /* ------------------------------------------------------------------------ */

  // Activates a step title (for example, "1 Choose a Data Source") and
  // deactivates the others. $descendant is an element nested under the step.
  function activateStepTitle($descendant) {
    var $h4 = $descendant.closest('tr').find('h4');
    if ($h4.hasClass('text-muted')) {
      $(topSelector + '> tbody > tr h4').addClass('text-muted');
      $h4.removeClass('text-muted');
    }
  }

  /*
  Updates a choice panel after it has been completed:

    1. Mutes text, including the title
    2. Disables inputs
    3. Hides unchecked radio buttons
    4. Hides the add and complete actions and shows the revisit action
  */
  function completePanel($panel) {
    $panel.addClass('text-muted');
    $panel.find('.panel-title span').addClass('text-muted');
    $panel.find('input[type="radio"]:not(:checked)').closest('.radio').hide();
    $panel.find('input, select, textarea').prop('disabled', true);
    $panel.find(':checked').closest('.radio').addClass('disabled');
    $panel.find('.action-add, .action-complete').hide();
    $panel.find('.action-revisit').show();
  }

  // Activates select radio buttons:
  //
  //   1. Shows radio buttons except those with a `filtered` class
  //   2. Selects/checks the first visible, enabled radio button
  //
  function activateRadio($panel) {
    $panel.find('.radio.filtered').hide();
    var $visibleRadio = $panel.find('.radio:not(.filtered)');
    var $enabledRadio = $visibleRadio
                           .find('input:not(.permanently-disabled)')
                           .closest('.radio');
    if ($enabledRadio.length > 0) {
      $enabledRadio.removeClass('disabled');
      if ($enabledRadio.find(':checked').length === 0)
        $enabledRadio.find('input').first().prop('checked', true);
      $panel.find('.action-complete').show();
    }
    $visibleRadio.show();
  }

  /*
  activatePanel() updates a choice panel after it has been activated: a choice
  is activated after a previous choice is completed or if it is revisited.
  activatePanel() makes these updates:

    1. Unmutes text, including the title
    2. Enables inputs except those with a permanently-disabled class
    3. Activates select radio buttons
    4. Hides the revisit action and shows the add and complete actions
    5. Activates the step title under which the choice is nested
  */
  function activatePanel($panel) {
    activateStepTitle($panel);
    $panel.removeClass('text-muted');
    $panel.find('.panel-title span').removeClass('text-muted');
    var $input = $panel.find('input, select, textarea');
    $input.filter(':not(.permanently-disabled)').prop('disabled', false);
    if ($panel.find('form:not(.form-paragraph)').length > 0)
      activateRadio($panel);
    else
      $panel.find('.action-complete').show();
    $panel.find('.action-add').show();
    $panel.find('.action-revisit').hide();
  }


  /* ------------------------------------------------------------------------ */
                    /* component factories */
  /* ------------------------------------------------------------------------ */

  // Returns an object that listens by calling other listeners.
  function listenerFactory(listeners) {
    return {
      listen: function() {
        listeners.forEach(function(listener) {
          listener.listen();
        });
      }
    };
  }

  function serviceChoiceFactory(options) {
    var selectors = options.serviceIds.map(function(id) {
      return topSelector + '#' + id;
    });
    var services = [
      {
        select: function() {
          $(selectors[0]).fadeTo('fast', 1);
        },
        deselect: function() {
          $(selectors[0]).fadeTo('fast', 0.5);
        }
      },
      {
        select: function() {
          var $service = $(selectors[1]);
          activateStepTitle($service);
          $service
            .fadeTo('fast', 1)
            .popover('show');
        },
        deselect: function() {
          $(selectors[1])
            .popover('hide')
            .fadeTo('fast', 0.5);
        }
      }
    ];
    return {
      listen: function() {
        $(document)
          .on('click', selectors[0], function(e) {
            e.preventDefault();
            services[1].deselect();
            services[0].select();
            options.nextElement.show();
          })
          .on('click', selectors[1], function(e) {
            e.preventDefault();
            options.nextElement.hide();
            services[0].deselect();
            services[1].select();
          });
      }
    };
  }

  function choiceListFactory(options) {
    var id = '#' + options.id;
    return {
      show: function() {
        var $choices = $(id);
        $choices.show();
        if (options.choices[options.choices.length - 1].state() === 'complete')
          options.nextElement.show();
        else
          activateStepTitle($choices);
      },
      hide: function() {
        options.nextElement.hide();
        $(id).hide();
      },
      listen: function() {
        options.choices.forEach(function(choice) {
          choice.listen();
        });
      }
    };
  }

  function choiceFactory(options) {
    var $panel, state;
    var choice = {
      state: state,
      complete: complete,
      revisit: revisit,
      listen: listen
    };
    if (options.type === 'radio')
      choice.val = valRadio;
    if (options.hidden) {
      choice.show = show;
      choice.hide = hide;
    }
    return choice;

    function state() {
      return state;
    }

    function activate() {
      if (state === 'active')
        return;
      if (options.beforeActivate)
        options.beforeActivate($panel);
      activatePanel($panel);
    }

    function show() {
      if (state !== 'hidden')
        return;
      activate();
      $panel.show();
      state = 'active';
    }

    function hide() {
      if (state === 'hidden')
        return;
      options.nextElement.hide();
      $panel.hide();
      state = 'hidden';
    }

    function complete() {
      if (state !== 'active')
        return;
      completePanel($panel);
      state = 'complete';
      options.nextElement.show();
    }

    function valRadio() {
      return $panel.find(':checked').val();
    }

    function revisit() {
      if (state !== 'complete')
        return;
      options.nextElement.hide();
      activate();
      state = 'active';
    }

    function listen() {
      // Adding a trailing space for ease of combining with other selectors.
      var selector = topSelector + '#' + options.id + ' ';
      $(document)
        .on('turbolinks:load', function() {
          $panel = $(selector);
          state = options.hidden ? 'hidden' : 'active';
        })
        .on('submit', selector, function(e) {
          e.preventDefault();
          complete();
        })
        .on('click', selector + '.action-revisit', function(e) {
          e.preventDefault();
          revisit();
        });
    }
  }

  function filteredChoiceFactory(options) {
    var filteredOptions = {
      type: 'radio',
      hidden: true,
      beforeActivate: beforeActivate
    };
    var combinedOptions = $.extend({}, options, filteredOptions);
    return choiceFactory(combinedOptions);

    function updateAddPath($choice) {
      var $addAction = $choice.find('.action-add');
      var path = $addAction
                   .data('path')
                   .replace('0', options.configuredServiceId());
      $addAction.find('a').prop('href', path);
    }

    function filterRadio($choice) {
      var $radio = $choice.find('.radio');
      $radio.addClass('filtered');
      var selector = '[data-configured-service-id="' +
        options.configuredServiceId() + '"]';
      $radio.filter(selector).removeClass('filtered');
    }

    function beforeActivate($choice) {
      updateAddPath($choice);
      filterRadio($choice);
    }
  }

  function finalizationFactory(id) {
    var selector = '#' + id;
    return {
      show: show,
      hide: hide
    };

    function updatePushUrl() {
      var $pushUrl = $('#push-url');
      var url = $pushUrl
                  .data('url')
                  .replace('/0', '/' + ServerChoice.val())
                  .replace('/1', '/' + FormChoice.val());
      $pushUrl.text(url);
    }

    function copyFields() {
      $('#data_source_id').val(FormChoice.val());
      $('#rule_data_field_name').val($('#field_name').val());
      $('#rule_type').val($('#rule_class').val());
      $('#rule_data_value').val($('#rule_value').val());
      $('#message').val($('#alert_message').val());
      $('#data_destination_id').val(RecipientListChoice.val());
    }

    function show() {
      updatePushUrl();
      copyFields();
      activateStepTitle($('#choices-data-destination'));
      $(selector).show();
    }

    function hide() {
      $(selector).hide();
    }
  }
})();
