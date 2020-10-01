

/* globals apex,fostr,$,$s */

var FOS = window.FOS || {};
FOS.exec = FOS.exec || {};

/**
 * Builds a nested object if it doesn't exist and assigns it a value
 *
 * @param {object}   obj             an object
 * @param {string}   keyPath         path expression with "." as separator
 * @param {string}   value           the value to be set at keyPath in obj
 */
FOS.exec.createNestedObjectAndAssign = function (obj, keyPath, value) {
    var keyPathArr = keyPath.split('.');
    var lastKeyIndex = keyPathArr.length - 1;
    var key;
    for (var i = 0; i < lastKeyIndex; ++i) {
        key = keyPathArr[i];
        if (!(key in obj)) {
            obj[key] = {};
        }
        obj = obj[key];
    }
    obj[keyPathArr[lastKeyIndex]] = value;
};

/**
 * This function implements the dynamic action and runs the configured pl/sql code in the database.
 * It also takes care of passing items back and forth, showing spinners, handling clobs.
 *
 * @param {object}   daContext                                Dynamic Action context as passed in by APEX
 * @param {object}   config                                   Configuration object holding the settings of the dynamic action
 * @param {string}   config.ajaxId                            Identifier necessary for APEX ajax communication. Will be passed to apex.server.plugin
 * @param {object}   config.pageItems                         Object holding information about items to be submitted and returned
 * @param {string}   config.pageItems.itemsToSubmit           List of page items needed to be passed with the ajax call
 * @param {string}   config.pageItems.itemsToReturn           List of page items needed to be returned from the ajax call
 * @param {object}   config.clobSettings                      Object holding configuration of clob info to be submitted and returned
 * @param {boolean}  config.clobSettings.submitClob           Whether a clob needs to be submitted into the ajax call
 * @param {string}   [config.clobSettings.submitClobFrom]     Indicator if the clob is taken from a page item or a js variable
 * @param {string}   [config.clobSettings.submitClobItem]     Name of a page item the clob is read from
 * @param {string}   [config.clobSettings.submitClobVariable] Name of a javascript variable the clob is read from
 * @param {boolean}  config.clobSettings.returnClob           Whether a clob needs to be returned from the ajax call
 * @param {string}   [config.clobSettings.returnClobFrom]     Indicator if the clob is returned to a page item or a js variable
 * @param {string}   [config.clobSettings.returnClobItem]     Name of a page item the clob is returned to
 * @param {string}   [config.clobSettings.returnClobVariable] Name of a javascript variable the clob is returned to
 * @param {object}   config.options                           Object holding further settings
 * @param {boolean}  config.options.suppressChangeEvent       When true there will be no change event raised on any item that will be changed
 * @param {boolean}  config.options.showErrorAsAlert          When true any error will be displayed in an alert
 * @param {boolean}  [config.options.performSubstitutions]    Whether the success or error message should perform item susbstitutions before being shown
 * @param {boolean}  [config.options.escapeMessage]           Whether to escape the success or error message before being shown
 * @param {function} [initFn]                                 Javascript Initialization Code Function, it can be undefined
 */
FOS.exec.plsql = function (daContext, config, initFn) {
    // constants
    var C_DANGER = 'danger';
    var C_ERROR = 'error';
    var C_INFO = 'info';
    var C_SUCCESS = 'success';
    var C_WARNING = 'warning';

    var fostrOptions = {};
    apex.debug.info('FOS - Execute PL/SQL Code', config);

    fostrOptions = {
        dismiss: ['onClick', 'onButton'],
        dismissAfter: 5000,
        newestOnTop: true,
        preventDuplicates: false,
        escapeHtml: false,
        position: 'top-right',
        iconClass: null,
        clearAll: false
    };

    // Allow the developer to perform any last (centralized) changes using Javascript Initialization Code setting
    // in addition to our plugin config we will pass in a 2nd object for configuring the FOS notifications
    if (initFn instanceof Function) {
        initFn.call(daContext, config, fostrOptions);
    }

    var afElements = daContext.affectedElements;
    var resumeCallback = daContext.resumeCallback;
    var ajaxId = config.ajaxId;
    var pageItems = config.pageItems;
    var spinnerSettings = config.spinnerSettings;
    var clobSettings = config.clobSettings;
    var options = config.options;
    var message, messageType, messageTitle;

    function _handleResponse(pData) {
        function _performActions(pData) {
            // this defines the list of actions we support
            var actionFuntions = {
                hideRegions: function (region) {
                    try {
                        apex.region(region).element.hide();
                    } catch (e) {
                        apex.debug.warn('.... Error hiding the following region: ' + region, e);
                    }
                },
                showRegions: function (region) {
                    try {
                        apex.region(region).element.show();
                    } catch (e) {
                        apex.debug.warn('.... Error showing the following region: ' + region, e);
                    }
                },
                hideItems: function (item) {
                    apex.item(item).hide();
                },
                showItems: function (item) {
                    apex.item(item).show();
                },
                enableItems: function (item) {
                    apex.item(item).enable();
                },
                disableItems: function (item) {
                    apex.item(item).disable();
                },
                hideButtons: function (button) {
                    apex.jQuery('#' + button).hide();
                },
                showButtons: function (button) {
                    apex.jQuery('#' + button).show();
                },
                enableButtons: function (button) {
                    apex.jQuery('#' + button).attr("disabled", false);
                },
                disableButtons: function (button) {
                    apex.jQuery('#' + button).attr("disabled", true);
                },
                setValues: function (item) {
                    $s(item.name, item.value, item.suppressChangeEvent);
                },
                clearErrors: function () {
                    apex.message.clearErrors();
                },
                itemErrors: function (item) {
                    var message = apex.util.applyTemplate(item.message, {
                        defaultEscapeFilter: null
                    });
                    apex.message.showErrors({
                        type: C_ERROR,
                        location: item.location || ['inline', 'page'],
                        pageItem: item.name,
                        message: message,
                        //any escaping is assumed to have been done by now
                        unsafe: false
                    });
                },
                refreshRegions: function (region) {
                    try {
                        apex.region(region).refresh();
                    } catch (e) {
                        apex.debug.warn('.... Error refreshing the following region: ' + region, e);
                    }
                },
                refreshItems: function (item) {
                    try {
                        apex.item(item).refresh();
                    } catch (e) {
                        apex.debug.warn('.... Error refreshing the following item: ' + item, e);
                    }
                },
                fireEvents: function (e) {
                    apex.event.trigger(e.selector || 'body', e.name, e.data);
                },
                removeClass: function (item) {
                    apex.jQuery(item.selector).removeClass(item.class);
                },
                addClass: function (item) {
                    apex.jQuery(item.selector).addClass(item.class);
                }
            };
            // iterate through our supported action functions and then through our data object to see which ones should be executed
            Object.entries(actionFuntions).forEach(function (action) {
                var method = action[0],
                    fn = action[1];
                if (method in pData && Array.isArray(pData[method])) {
                    pData[method].forEach(fn);
                }
            });

            // Optionally set the focus on a page item
            if (pData.setFocusItem) {
                try {
                    apex.item(pData.setFocusItem).setFocus();
                } catch (e) {
                    apex.debug.warn('.... Error setting focus the following item: ' + pData.setFocusItem, e);
                }
            }

        } // eof _performActions

        // Main handling
        if (pData.status == C_SUCCESS) {
            var itemCount, itemArray, cancelActions = false;

            // check if the developer wants to cancel following actions
            cancelActions = !!pData.cancelActions; // ensure we have a boolean response if attribute is undefined

            //regular page items
            if (pData && pData.items) {
                itemArray = pData.items;
                itemCount = itemArray.length;
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
                        FOS.exec.createNestedObjectAndAssign(window, clobSettings.returnClobVariable, pData.clob);
                        break;
                    case 'javascriptvariablejson':
                        pData.execPlsqlResult = JSON.parse(pData.clob);
                        FOS.exec.createNestedObjectAndAssign(window, clobSettings.returnClobVariable, pData.execPlsqlResult);
                        _performActions(pData.execPlsqlResult);
                        break;
                }
            }

            // Notification overrides from developer
            if (pData.execPlsqlResult && pData.execPlsqlResult.notification) {
                var notification = pData.execPlsqlResult.notification;
                pData.message = notification.message;
                pData.messageType = notification.type;
                pData.messageTitle = notification.title;
            }

            // Notification
            if (pData.message) {
                messageType = (pData.messageType && [C_INFO, C_WARNING, C_SUCCESS, C_ERROR, C_DANGER].includes(pData.messageType)) ? pData.messageType : C_SUCCESS;
                messageType = (messageType === C_DANGER) ? C_ERROR : messageType;

                messageTitle = pData.messageTitle;
                message = pData.message;

                // performing client-side item susbstitutions
                if (messageTitle && options.performSubstitutions) {
                    messageTitle = apex.util.applyTemplate(messageTitle, { defaultEscapeFilter: null });
                }
                if (message && options.performSubstitutions) {
                    message = apex.util.applyTemplate(message, { defaultEscapeFilter: null });
                }

                // performing escaping
                if (messageTitle && options.escapeMessage) {
                    messageTitle = apex.util.escapeHTML(messageTitle);
                }
                if (message && options.escapeMessage) {
                    message = apex.util.escapeHTML(message);
                }

                // notify
                $.extend(fostrOptions, {
                    message: (messageTitle) ? message : undefined,
                    title: (!messageTitle) ? message : messageTitle,
                    type: messageType,
                    dismissAfter: (messageType === C_ERROR) ? undefined : fostrOptions.dismissAfter
                });
                fostr[messageType](fostrOptions);
            }
            // Optionally fire an event if the developer deifned one using apex_application.g_x05
            if (pData.eventName) {
                apex.event.trigger('body', pData.eventName, pData);
            }

            /* Resume execution of actions here and pass false to the callback, to indicate no
            error has occurred with the Ajax call. */
            apex.da.resume(resumeCallback, cancelActions);
        } else if (pData.status == C_ERROR) {
            if (pData.message) {
                // perform any substitutions
                messageTitle = pData.messageTitle;
                message = pData.message;

                if (messageTitle && options.performSubstitutions) {
                    messageTitle = apex.util.applyTemplate(messageTitle, { defaultEscapeFilter: null });
                }
                if (message && options.performSubstitutions) {
                    message = apex.util.applyTemplate(message, { defaultEscapeFilter: null });
                }

                // performing escaping
                if (messageTitle && options.escapeMessage) {
                    messageTitle = apex.util.escapeHTML(messageTitle);
                }
                if (message && options.escapeMessage) {
                    message = apex.util.escapeHTML(message);
                }

                if (options.showErrorAsAlert) {
                    apex.message.alert(message);
                } else {
                    $.extend(fostrOptions, {
                        message: (messageTitle) ? message : undefined,
                        title: (!messageTitle) ? message : messageTitle,
                        type: C_ERROR,
                        dismissAfter: undefined
                    });
                    fostr.error(fostrOptions);

                    // Optionally fire an event if the developer defined one using apex_application.g_x05
                    if (pData.eventName) {
                        apex.event.trigger('body', pData.eventName, pData);
                    }
                }
            }
        }
    }

    var clobToSubmit;

    if (clobSettings.submitClob) {
        switch (clobSettings.submitClobFrom) {
            case 'pageitem':
                clobToSubmit = apex.item(clobSettings.submitClobItem).getValue();
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

    var loadingIndicatorFn;

    //configures the showing and hiding of a possible spinner
    if (spinnerSettings.showSpinner) {
        // work out where to show the spinner
        spinnerSettings.spinnerElement = (spinnerSettings.showSpinnerOnRegion) ? afElements : 'body';
        loadingIndicatorFn = (function (element, showOverlay) {
            var fixedOnBody = element == 'body';
            return function (pLoadingIndicator) {
                var overlay$;
                var spinner$ = apex.util.showSpinner(element, { fixed: fixedOnBody });
                if (showOverlay) {
                    overlay$ = $('<div class="fos-region-overlay' + (fixedOnBody ? '-fixed' : '') + '"></div>').prependTo(element);
                }
                function removeSpinner() {
                    if (overlay$) {
                        overlay$.remove();
                    }
                    spinner$.remove();
                }
                //this function must return a function which handles the removing of the spinner
                return removeSpinner;
            };
        })(spinnerSettings.spinnerElement, spinnerSettings.showSpinnerOverlay);
    }

    // run the pl/sql code in the database
    var result = apex.server.plugin(ajaxId, {
        pageItems: pageItems.itemsToSubmit,
        p_clob_01: clobToSubmit
    }, {
        dataType: 'json',
        loadingIndicator: loadingIndicatorFn,
        target: daContext.browserEvent.target
    });

    // handle ajax result using our result promise
    result.done(function (data) {
        _handleResponse(data);
    }).fail(function (jqXHR, textStatus, errorThrown) {
        apex.da.handleAjaxErrors(jqXHR, textStatus, errorThrown, resumeCallback);
    });
};




