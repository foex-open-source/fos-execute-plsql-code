window.FOS    = window.FOS    || {};
FOS.execPlSql = FOS.execPlSql || {};

FOS.execPlSql.showSpinner = function (config) {

    apex.debug.info('FOS - Execute PL/SQL Code', config);

    var selector = config.selector;
    var displayOverlay = config.displayOverlay;

    var lSpinner;
    var lWaitPopup$;

    if (displayOverlay) {
        var bodyStyle = 'position: fixed;    z-index: 1900; visibility: visible; width: 100%; height: 100%; background: rgba(255, 255, 255, 0.5);';
        var normalStyle = 'position: absolute; z-index: 440;  visibility: visible; width: 100%; height: 100%; background: rgba(255, 255, 255, 0.5);';

        lWaitPopup$ = $('<div style="' + (selector == 'body' ? bodyStyle : normalStyle) + '"></div>').prependTo($(selector));
    }

    lSpinner = apex.util.showSpinner(selector, (selector == 'body' ? { fixed: true } : { spinnerClass: 'au-execute-customSpinnerClass' }));

    return {
        remove: function () {
            if (lWaitPopup$ !== undefined) {
                lWaitPopup$.remove();
            }
            if (lSpinner !== undefined) {
                lSpinner.remove();
            }
        }
    };
};

//builds a nested object if it doesn't exist and assigns it a value
FOS.execPlSql.createNestedObjectAndAssign = function (obj, keyPath, value) {
    keyPath = keyPath.split('.');
    lastKeyIndex = keyPath.length - 1;
    for (var i = 0; i < lastKeyIndex; ++i) {
        key = keyPath[i];
        if (!(key in obj)) {
            obj[key] = {};
        }
        obj = obj[key];
    }
    obj[keyPath[lastKeyIndex]] = value;
};

FOS.execPlSql.executePlSqlCode = function (daContext, config) {
    apex.debug.info('FOS - Execute PL/SQL Code ', config);

    var action = daContext.action;
    var resumeCallback = daContext.resumeCallback;
    var ajaxId = config.ajaxId;
    var pageItems = config.pageItems;
    //var loaderSettings = config.loaderSettings;
    var clobSettings = config.clobSettings;
    var options = config.options;

    function _handleResponse(pData) {
        if (pData.status == 'success') {
            var itemCount, itemArray;
            //regular page items
            if (pData && pData.items) {
                itemCount = pData.items.length;
                itemArray = pData.items;
                for (var i = 0; i < itemCount; i++) {
                    $s(itemArray[i].id, itemArray[i].value, null, options.suppressChangeEvent);
                }
            }

            //clob page item/ variable/ variable as json
            if (clobSettings.returnClob) {
                switch (clobSettings.returnClobInto) {
                    case 'pageitem':
                        $s(clobSettings.returnClobItem, pData.clob, null, options.suppressChangeEvent);
                        break;
                    case 'javascriptvariable':
                        FOS.execPlSql.createNestedObjectAndAssign(window, clobSettings.returnClobVariable, pData.clob);
                        break;
                    case 'javascriptvariablejson':
                        FOS.execPlSql.createNestedObjectAndAssign(window, clobSettings.returnClobVariable, JSON.parse(pData.clob));
                        break;
                    default:
                        break;
                }
            }

            if (pData.message) {
                apex.message.showPageSuccess(pData.message);
            }

            /* Resume execution of actions here and pass false to the callback, to indicate no
            error has occurred with the Ajax call. */
            apex.da.resume(resumeCallback, false);
        } else if (pData.status == 'error') {
            if (pData.message) {

                if (options.showErrorAsAlert) {
                    apex.message.alert(pData.message);
                } else {
                    // First clear the errors
                    apex.message.clearErrors();

                    // Now show new errors
                    apex.message.showErrors({
                        type: 'error',
                        location: 'page',
                        message: pData.message,
                        unsafe: false
                    });
                }
            }
        }
    }

    var lSpinner$;
    var uniqueId = new Date().getTime();

    /*
    if (loaderSettings.showLoader) {
        apex.util.delayLinger.start(uniqueId, function () {
            lSpinner$ = FOS.execPlSql.showSpinner({
                selector: loaderSettings.loaderPosition,
                showOverlay: (loaderSettings.loaderType == 'spinnerandoverlay')
            });
        });
    }
    */

    /*
    var handle_spinner = function () {
        if (loaderSettings.showLoader) {
            apex.util.delayLinger.finish(uniqueId, function () {
                if (lSpinner$) {
                    lSpinner$.remove();
                }
            });
        }
    };
    */

    var clobToSubmit;

    if (clobSettings.submitClob) {
        switch (clobSettings.submitClobFrom) {
            case 'pageitem':
                clobToSubmit = item(clobSettings.submitClobItem).getValue();
                break;
            case 'javascriptvariable':
                var toSubmit = window[clobSettings.submitClobVariable];

                if (toSubmit instanceof Object) {
                    clobToSubmit = JSON.stringify(toSubmit);
                } else {
                    clobToSubmit = toSubmit;
                }
                break;
            default:
                break;
        }
    }

    var result = apex.server.plugin(ajaxId, {
        pageItems: pageItems.itemsToSubmit,
        p_clob_01: clobToSubmit
    }, {
        dataType: 'json',
        loadingIndicator: pageItems.itemsToReturn.map(item => '#' + item).join(','),
        target: daContext.browserEvent.target
    });

    result.done(function(data){
        _handleResponse(data);
    }).fail(function(jqXHR, textStatus, errorThrown){
        apex.da.handleAjaxErrors(jqXHR, textStatus, errorThrown, resumeCallback);
    }).always(function(){
        //handle_spinner();
    });
};


