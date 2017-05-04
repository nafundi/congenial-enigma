(function() {
  var ODKService = {
    select: function() {
      DHIS2Service.deselect();
      $('#service-odk').fadeTo('fast', 1);
      ODKChoices.show();
      if (FormChoice.is_complete())
        AlertForm.show();
      return this;
    },
    deselect: function() {
      AlertForm.hide();
      ODKChoices.hide();
      $('#service-odk').fadeTo('fast', 0.5);
      return this;
    },
    listen: function() {
      $(document).on('click', '#new-integration #service-odk', this.select);
      return this;
    }
  };

  var DHIS2Service = {
    select: function() {
      ODKService.deselect();
      $('#service-dhis2')
        .fadeTo('fast', 1)
        .popover('show');
      return this;
    },
    deselect: function() {
      $('#service-dhis2')
        .popover('hide')
        .fadeTo('fast', 0.5);
      return this;
    },
    listen: function() {
      $(document).on('click', '#new-integration #service-dhis2', this.select);
      return this;
    }
  };

  var ODKChoices = {
    show: function() {
      $('#choices-odk').show();
      return this;
    },
    hide: function() {
      $('#choices-odk').hide();
      return this;
    }
  };

  var ServerChoice = {
    change: function() {
      $('#choice-server .action-choose').show();
      return this;
    },
    val: function() {
      return $('#choice-server :checked').val();
    },
    choose: function() {
      // Hide all elements other than the checked radio button.
      var $choice = $('#choice-server');
      $choice.find('.panel-body').children().hide();
      $choice.find(':checked').closest('.radio').show();

      $choice.find('.action-modify').show();
      FormChoice.show();
      return this;
    },
    modify: function() {
      FormChoice.hide();
      var $choice = $('#choice-server');
      $choice.find('.panel-body').children().show();
      $choice.find('.action-modify').hide();
      return this;
    },
    listen: function() {
      var self = this;
      $(document)
        .on('change', '#new-integration #choice-server input', this.change)
        .on('click', '#new-integration #choice-server .action-choose', this.choose)
        .on('click', '#new-integration #choice-server .action-modify', function(e) {
          e.preventDefault();
          self.modify();
        });
      return this;
    }
  };

  var FormChoice = (function() {
    var $choice, is_complete;

    return {
      is_complete: is_complete,
      show: show,
      hide: hide,
      change: change,
      val: val,
      choose: choose,
      modify: modify,
      listen: listen
    };

    function is_complete() {
      return is_complete;
    }

    // Shows the existing forms for the selected server.
    function readyForms() {
      var selector = '[data-configured-service-id=' + ServerChoice.val() + ']';
      var $forms = $choice.find('.radio').filter(selector);
      $forms.show();
      return $forms;
    }

    // Shows the add action.
    function readyAddAction() {
      var $addAction = $choice.find('.action-add');
      var path = $addAction.data('path').replace('0', ServerChoice.val());
      $addAction.find('a').prop('href', path);
      $addAction.show();
    }

    // Shows the choose action if a form has been selected.
    function readyChooseAction($forms) {
      if ($forms.find(':checked').length > 0)
        $choice.find('.action-choose').show();
    }

    function readySelection() {
      $choice.find('.panel-body').children().hide();
      var $forms = readyForms();
      readyAddAction();
      readyChooseAction($forms);
    }

    function show() {
      readySelection();
      $choice.show();
      return this;
    }

    function hide() {
      AlertForm.hide();
      $choice.hide();
      is_complete = false;
      return this;
    }

    function change() {
      $choice.find('.action-choose').show();
      return this;
    }

    function val() {
      return $choice.find(':checked').val();
    }

    function choose() {
      // Hide all elements other than the checked radio button.
      $choice.find('.panel-body').children().hide();
      $choice.find(':checked').closest('.radio').show();

      $choice.find('.action-modify').show();
      AlertForm.show();

      is_complete = true;

      return this;
    }

    function modify() {
      AlertForm.hide();
      readySelection();
      is_complete = false;
      return this;
    }

    function listen() {
      $(document)
        .on('turbolinks:load', function() {
          $choice = $('#new-integration #choice-form');
          is_complete = false;
        })
        .on('change', '#new-integration #choice-form input', change)
        .on('click', '#new-integration #choice-form .action-choose', choose)
        .on('click', '#new-integration #choice-form .action-modify', function(e) {
          e.preventDefault();
          modify();
        });
      return this;
    }
  })();

  var AlertForm = {
    updatePushUrl: function() {
      var $pushUrl = $('#push-url');
      var url = $pushUrl
                  .data('url')
                  .replace('/0', '/' + ServerChoice.val())
                  .replace('/1', '/' + FormChoice.val());
      $pushUrl.text(url);
    },
    show: function() {
      $('#data_source_id').val(FormChoice.val());
      this.updatePushUrl();
      $('#alert-form').show();
    },
    hide: function() {
      $('#alert-form').hide();
    }
  };

  ODKService.listen();
  DHIS2Service.listen();
  ServerChoice.listen();
  FormChoice.listen();
})();
