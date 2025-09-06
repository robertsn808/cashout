app.controller('gameCtrl', function ($scope, $http, $log) {
    var TAB_MY_ACCOUNT_PROFILE = 'profile';
    var TAB_CASHIER_PAYMENT = 'payment'

    $scope.myAccountActiveTab = TAB_MY_ACCOUNT_PROFILE;
    $scope.cashierActiveTab = TAB_CASHIER_PAYMENT;
    $scope.levelActiveTab = TAB_CASHIER_PAYMENT;

    $scope.setActiveTab = function(e, name) {
        e.preventDefault();

        if (name === 'vip') {
            $('body').removeClass('overflow');
        } else {
            $('body').addClass('overflow');
        }

        if ($scope.myAccountActiveTab !== name) {
            $scope.myAccountActiveTab = name;
        }
    }

    $scope.isActiveTab = function(name) {
        return $scope.myAccountActiveTab === name;
    };

    $scope.setActiveSubTab = function(e, name) {
        e.preventDefault();
        if ($scope.cashierActiveTab !== name) {
            $scope.cashierActiveTab = name;
        }
    }

    $scope.isActiveSubTab = function(name) {
        return $scope.cashierActiveTab === name;
    };

    $scope.openModal = function(e, id) {
        e.preventDefault();
        
        $scope.closeModal(e);

        $(id).show();
        $('#lock__screen').show();
        $('body').addClass('overflow');
    }

    $scope.closeModal = function(e) {
        e.preventDefault();
        var $modal = $('.modal');

        $('input, textarea', $modal).removeClass('is__invalid');
        $('.invalid__feedback', $modal).remove();
        $('.modal__error, .modal-loading', $modal).hide();
        $modal.hide();
        $('#lock__screen').hide();
        $('body').removeClass('overflow');
    }

    $scope.sendForm = function(e) {
        e.preventDefault();

        var $form = $(e.target);
        var $modal = $form.closest('.modal');

        $('input, textarea', $form).removeClass('is__invalid');
        $('.invalid__feedback', $form).remove();
        $('.modal__error', $form).hide().text('');
        $('.modal-preloader', $modal).show();

        $.ajax({
            type: $form.attr('method'),
            url: $form.attr('action'),
            data: $form.serialize(),
            success: function(data) {
				$('.modal-preloader', $modal).hide();
				$form.find("input, select, textarea").val("");
                // Handle both JSON and full HTML responses gracefully
                if (typeof data === 'object' && data !== null && data.link) {
                    location.replace(data.link);
                } else {
                    // For non-JSON (HTML) responses or any unexpected payloads, reload to reflect auth state
                    location.reload();
                }
            },
            error: function (xhr) {
                var message = 'Login failed. Please check your credentials.';
                var payload = null;
                try {
                    payload = xhr.responseJSON || JSON.parse(xhr.responseText);
                } catch (e) {
                    payload = null;
                }

                // Laravel validation style: {message: ..., errors: {field: [msg]}}
                if (payload && payload.errors) {
                    var agg = [];
                    $.each(payload.errors, function (key, value) {
                        var field = $('input[name="'+ key +'"], textarea[name="'+ key +'"]', $form);
                        var first = Array.isArray(value) ? value[0] : (typeof value === 'string' ? value : 'Invalid value');
                        if (field.length) {
                            field.addClass('is__invalid')
                                .parent()
                                .append('<div class="invalid__feedback">'+ first +'</div>');
                        } else {
                            agg.push(first);
                        }
                    });
                    if (agg.length) {
                        $('.modal__error', $form).show().html(agg.join('<br/>'));
                    }
                } else if (payload) {
                    // Array of messages or plain string
                    if (Array.isArray(payload)) {
                        $('.modal__error', $form).show().html(payload.join('<br/>'));
                    } else if (typeof payload === 'string') {
                        $('.modal__error', $form).show().text(payload);
                    } else if (payload.message) {
                        $('.modal__error', $form).show().text(payload.message);
                    } else {
                        $('.modal__error', $form).show().text(message);
                    }
                } else {
                    $('.modal__error', $form).show().text(message);
                }

                $('.modal-preloader', $modal).hide();
            },
        });
    };
});
