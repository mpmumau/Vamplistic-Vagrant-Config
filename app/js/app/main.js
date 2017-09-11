(function(window, document, $) {
    console.log("Testeroo Moo");

    var ViewStates = {
        System: 0,
        Packages: 1,
        Info: 2
    };

    var App = {
        View: {
            clear: function()
            {
                console.log("clearing");
                var panels = [
                    '#system-panel',
                    '#packages-panel',
                    '#info-panel'
                ]

                $.each(panels, function(key, panel) {
                    console.log("clear: " + panel);
                    $(panel).removeClass('show-block');
                    $(panel).addClass('hidden');
                });
            },
            set: function(state) 
            {
                this.clear();

                var show = function($el)
                {
                    $el.removeClass('hidden');
                    $el.addClass('show-block');
                };

                switch(state)
                {
                    case ViewStates.System:
                        show($("#system-panel"));
                        break;
                    case ViewStates.Packages:
                        show($("#packages-panel"));
                        break;
                    case ViewStates.Info:
                        show($("#info-panel"));
                        break;
                };
            }
        }
    };

    $(".system-panel").on('click', function(e) {
        e.preventDefault();
        App.View.set(ViewStates.System);
    });

    $(".packages-panel").on('click', function(e) {
        e.preventDefault();
        App.View.set(ViewStates.Packages);
    });

    $(".info-panel").on('click', function(e) {
        e.preventDefault();
        App.View.set(ViewStates.Info);
    });

    window.ViewStates = ViewStates;
    window.App = App;
    
})(window, document, jQuery);

