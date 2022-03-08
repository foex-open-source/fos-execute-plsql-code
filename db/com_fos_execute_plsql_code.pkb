create or replace package body com_fos_execute_plsql_code
as

-- =============================================================================
--
--  FOS = FOEX Open Source (fos.world), by FOEX GmbH, Austria (www.foex.at)
--
--  This is an improved version of "Execute PL/SQL Code" dynamic action.
--
--  License: MIT
--
--  GitHub: https://github.com/foex-open-source/fos-execute-plsql-code
--
-- =============================================================================
g_in_error_handling_callback boolean := false;

--------------------------------------------------------------------------------
-- private function to include the apex error handling function, if one is
-- defined on application or page level
--------------------------------------------------------------------------------
function error_function_callback
  ( p_error in apex_error.t_error
  )  return apex_error.t_error_result
is
    c_cr constant varchar2(1) := chr(10);

    l_error_handling_function apex_application_pages.error_handling_function%type;
    l_statement               varchar2(32767);
    l_result                  apex_error.t_error_result;

    procedure log_value
      ( p_attribute_name in varchar2
      , p_old_value      in varchar2
      , p_new_value      in varchar2
      )
    is
    begin
        if   p_old_value <> p_new_value
          or (p_old_value is not null and p_new_value is null)
          or (p_old_value is null     and p_new_value is not null)
        then
            apex_debug.info('%s: %s', p_attribute_name, p_new_value);
        end if;
    end log_value;

begin
    if not g_in_error_handling_callback
    then
        g_in_error_handling_callback := true;

        begin
            select /*+ result_cache */
                   coalesce(p.error_handling_function, f.error_handling_function)
              into l_error_handling_function
              from apex_applications f,
                   apex_application_pages p
             where f.application_id     = apex_application.g_flow_id
               and p.application_id (+) = f.application_id
               and p.page_id        (+) = apex_application.g_flow_step_id;
        exception when no_data_found then
            null;
        end;
    end if;

    if l_error_handling_function is not null
    then
        l_statement := 'declare'||c_cr||
                           'l_error apex_error.t_error;'||c_cr||
                       'begin'||c_cr||
                           'l_error := apex_error.g_error;'||c_cr||
                           'apex_error.g_error_result := '||l_error_handling_function||' ('||c_cr||
                               'p_error => l_error );'||c_cr||
                       'end;';

        apex_error.g_error := p_error;

        begin
            apex_exec.execute_plsql(l_statement);
        exception when others then
            apex_debug.error('error in error handler: %s', sqlerrm);
            apex_debug.error('backtrace: %s', dbms_utility.format_error_backtrace);
        end;

        l_result := apex_error.g_error_result;

        if l_result.message is null
        then
            l_result.message          := nvl(l_result.message,          p_error.message);
            l_result.additional_info  := nvl(l_result.additional_info,  p_error.additional_info);
            l_result.display_location := nvl(l_result.display_location, p_error.display_location);
            l_result.page_item_name   := nvl(l_result.page_item_name,   p_error.page_item_name);
            l_result.column_alias     := nvl(l_result.column_alias,     p_error.column_alias);
        end if;
    else
        l_result.message          := p_error.message;
        l_result.additional_info  := p_error.additional_info;
        l_result.display_location := p_error.display_location;
        l_result.page_item_name   := p_error.page_item_name;
        l_result.column_alias     := p_error.column_alias;
    end if;

    if l_result.message = l_result.additional_info
    then
        l_result.additional_info := null;
    end if;

    g_in_error_handling_callback := false;

    return l_result;

exception
    when others then
        l_result.message             := 'custom apex error handling function failed !!';
        l_result.additional_info     := null;
        l_result.display_location    := apex_error.c_on_error_page;
        l_result.page_item_name      := null;
        l_result.column_alias        := null;
        g_in_error_handling_callback := false;

        return l_result;
end error_function_callback;

--
-- Cater for display values
-- Thanks: Pavel Glebov (glebovpavel)
--
function get_display_value
  ( p_item_name in apex_application_page_items.item_name%type,
    p_value     in varchar2
  ) return varchar2
is
    l_display_as_code     apex_application_page_items.display_as_code%type;
    l_lov_named_lov       apex_application_page_items.lov_named_lov%type;
    l_lov_definition      apex_application_page_items.lov_definition%type;
    l_lov_display_null    apex_application_page_items.lov_display_null%type;
    l_lov_null_text       apex_application_page_items.lov_null_text%type;
    l_app_id              apex_application_page_items.application_id%type    := nv('APP_ID');
    l_page_id             apex_application_page_items.page_id%type           := nv('APP_PAGE_ID');
begin
    begin
        select display_as_code
             , lov_named_lov
             , lov_definition
             , lov_display_null
             , lov_null_text
          into l_display_as_code
             , l_lov_named_lov
             , l_lov_definition
             , l_lov_display_null
             , l_lov_null_text
          from apex_application_page_items
         where application_id  = l_app_id
           and page_id        in (wwv_flow.g_global_page_id, l_page_id) -- Bug fix: added support for page zero items - thanks mbrde
           and item_name       = p_item_name
        ;
    exception
        when no_data_found then
            raise_application_error(-20001,'Item '||p_item_name||' not found!');
    end;

    if l_display_as_code != 'NATIVE_POPUP_LOV'
    then
        return '';
    end if;

    if l_lov_display_null = 'Yes'
    then
        null;
    else
        l_lov_null_text := '';
    end if;

    if l_lov_named_lov is not null
    then
        return apex_item.text_from_lov
          ( p_value     => p_value
          , p_lov       => l_lov_named_lov
          , p_null_text => l_lov_null_text
          );
    else
        return apex_item.text_from_lov_query
          ( p_value     => p_value
          , p_query     => l_lov_definition
          , p_null_text => l_lov_null_text
          );
    end if;
end get_display_value;

--------------------------------------------------------------------------------
-- this render function sets up a javascript function which will be called
-- when the dynamic action is executed.
-- all relevant configuration settings will be passed to this function as JSON
--------------------------------------------------------------------------------
function render
  ( p_dynamic_action apex_plugin.t_dynamic_action
  , p_plugin         apex_plugin.t_plugin
  )
return apex_plugin.t_dynamic_action_render_result
is
    -- l_result is necessary for the plugin infrastructure
    l_result                   apex_plugin.t_dynamic_action_render_result;

    l_ajax_id                  varchar2(4000) := apex_plugin.get_ajax_identifier;

    -- read plugin parameters and store in local variables
    l_items_to_submit          apex_t_varchar2 := apex_string.split(p_dynamic_action.attribute_02, ',');
    l_items_to_return          apex_t_varchar2 := apex_string.split(p_dynamic_action.attribute_03, ',');

    l_submit_clob              p_dynamic_action.attribute_06%type := p_dynamic_action.attribute_06;
    l_submit_clob_item         p_dynamic_action.attribute_07%type := p_dynamic_action.attribute_07;
    l_submit_clob_variable     p_dynamic_action.attribute_08%type := p_dynamic_action.attribute_08;

    l_return_clob              p_dynamic_action.attribute_09%type := p_dynamic_action.attribute_09;
    l_return_clob_item         p_dynamic_action.attribute_10%type := p_dynamic_action.attribute_10;
    l_return_clob_variable     p_dynamic_action.attribute_11%type := p_dynamic_action.attribute_11;

    --extra options
    l_suppress_change_event    boolean := instr(p_dynamic_action.attribute_15, 'suppressChangeEvent')  > 0;
    l_show_error_as_alert      boolean := instr(p_dynamic_action.attribute_15, 'showErrorAsAlert')     > 0;
    l_show_spinner             boolean := instr(p_dynamic_action.attribute_15, 'showSpinner')          > 0;
    l_show_spinner_overlay     boolean := instr(p_dynamic_action.attribute_15, 'showSpinnerOverlay')   > 0;
    l_show_spinner_on_region   boolean := instr(p_dynamic_action.attribute_15, 'spinnerPosition')      > 0;
    l_replace_on_client        boolean := instr(p_dynamic_action.attribute_15, 'client-substitutions') > 0;
    l_escape_message           boolean := instr(p_dynamic_action.attribute_15, 'escape-message')       > 0;

    -- Javascript Initialization Code
    l_init_js_fn               varchar2(32767) := nvl(apex_plugin_util.replace_substitutions(p_dynamic_action.init_javascript_code), 'undefined');

begin
    -- standard debugging intro, but only if necessary
    if apex_application.g_debug and substr(:DEBUG,6) >= 6
    then
        apex_plugin_util.debug_dynamic_action
          ( p_plugin         => p_plugin
          , p_dynamic_action => p_dynamic_action
          );
    end if;

    -- check if we need to add our toastr plugin library files
    apex_css.add_file
      ( p_name           => apex_plugin_util.replace_substitutions('fostr#MIN#.css')
      , p_directory      => p_plugin.file_prefix || 'css/'
      , p_skip_extension => true
      , p_key            => 'fostr'
      );
    apex_javascript.add_library
      ( p_name           => apex_plugin_util.replace_substitutions('fostr#MIN#.js')
      , p_directory      => p_plugin.file_prefix || 'js/'
      , p_skip_extension => true
      , p_key            => 'fostr'
      );

    -- create a JS function call passing all settings as a JSON object
    --
    -- FOS.execPlSql.executePlSqlCode(this, {
    --     "ajaxId": "SDtjkD9_TUyDJZzOzlRKnFkZWTFWkOqJrwNuJyUzooI",
    --     "pageItems": {},
    --     "clobSettings": {
    --         "submitClob": false,
    --         "returnClob": false
    --     },
    --     "options": {
    --         "suppressChangeEvent": false,
    --         "showErrorAsAlert": true
    --     }
    -- });
    apex_json.initialize_clob_output;
    apex_json.open_object;

    apex_json.write('ajaxId'             , l_ajax_id);

    apex_json.open_object('pageItems');
    apex_json.write('itemsToSubmit'      , l_items_to_submit);
    apex_json.write('itemsToReturn'      , l_items_to_return);
    apex_json.close_object;

    apex_json.open_object('spinnerSettings');
    apex_json.write('showSpinner'        , l_show_spinner);
    apex_json.write('showSpinnerOverlay' , l_show_spinner_overlay);
    apex_json.write('showSpinnerOnRegion', l_show_spinner_on_region);
    apex_json.close_object;

    apex_json.open_object('clobSettings');
    apex_json.write('submitClob'         , l_submit_clob is not null);
    apex_json.write('submitClobFrom'     , l_submit_clob);
    apex_json.write('submitClobItem'     , l_submit_clob_item);
    apex_json.write('submitClobVariable' , l_submit_clob_variable);
    apex_json.write('returnClob'         , l_return_clob is not null);
    apex_json.write('returnClobInto'     , l_return_clob);
    apex_json.write('returnClobItem'     , l_return_clob_item);
    apex_json.write('returnClobVariable' , l_return_clob_variable);
    apex_json.close_object;

    apex_json.open_object('options');
    apex_json.write('suppressChangeEvent' , l_suppress_change_event);
    apex_json.write('showErrorAsAlert'    , l_show_error_as_alert);
    apex_json.write('performSubstitutions', l_replace_on_client);
    apex_json.write('escapeMessage'       , l_escape_message);
    apex_json.close_object;

    apex_json.close_object;
    l_result.javascript_function := 'function(){FOS.exec.plsql(this, '|| apex_json.get_clob_output || ', '|| l_init_js_fn ||');}';

    apex_json.free_output;

    -- all done, return l_result now containing the javascript function
    return l_result;
end render;

--------------------------------------------------------------------------------
-- the ajax function is invoked from the clientside dynamic action to execute
-- the configured pl/sql code.
-- page items and a clob can be passend into this function, it is also able to
-- return new item values and clob output.
-- clob values passed in (clob to submit) is accessible as apex_application.g_clob_01
--------------------------------------------------------------------------------
function ajax
  ( p_dynamic_action apex_plugin.t_dynamic_action
  , p_plugin         apex_plugin.t_plugin
  )
return apex_plugin.t_dynamic_action_ajax_result
is
    -- error handling
    l_apex_error       apex_error.t_error;
    l_result           apex_error.t_error_result;
    -- return type which is necessary for the plugin infrastructure
    l_return           apex_plugin.t_dynamic_action_ajax_result;

    -- read plugin parameters and store in local variables
    l_statement         p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;
    l_items_to_return   p_dynamic_action.attribute_03%type := p_dynamic_action.attribute_03;
    l_success_message   p_dynamic_action.attribute_04%type := p_dynamic_action.attribute_04;
    l_error_message     p_dynamic_action.attribute_05%type := p_dynamic_action.attribute_05;
    l_return_clob       boolean                            := p_dynamic_action.attribute_09 is not null;

    l_escape_message    boolean := instr(p_dynamic_action.attribute_15, 'escape-message')       > 0;
    l_replace_on_client boolean := instr(p_dynamic_action.attribute_15, 'client-substitutions') > 0;

    l_message          varchar2(32767);
    l_message_title    varchar2(32767);
    l_item_names       apex_t_varchar2;
    l_value            varchar2(32767);

    --
    -- We won't escape serverside if we do it client side to avoid double escaping
    --
    function escape_html
      ( p_html                   in varchar2
      , p_escape_already_enabled in boolean
      ) return varchar2
    is
    begin
        return case when p_escape_already_enabled then p_html else apex_escape.html(p_html) end;
    end escape_html;

begin
    -- standard debugging intro, but only if necessary
    if apex_application.g_debug and substr(:DEBUG,6) >= 6
    then
        apex_plugin_util.debug_dynamic_action
          ( p_plugin         => p_plugin
          , p_dynamic_action => p_dynamic_action
          );
    end if;

    ----------------------------------------------------------------------------
    -- this now runs the actual PL/SQL code
    ----------------------------------------------------------------------------
    apex_exec.execute_plsql(p_plsql_code => l_statement);

    -- prepare a json object as response for the client
    apex_json.initialize_output;
    apex_json.open_object;

    -- add return items+values to json
    if l_items_to_return is not null
    then
        l_item_names := apex_string.split(l_items_to_return, ',');

        apex_json.open_array('items');

        for l_idx in 1 .. l_item_names.count
        loop
            apex_json.open_object;
            apex_json.write('id', apex_plugin_util.item_names_to_dom
                                    ( p_item_names     => l_item_names(l_idx)
                                    , p_dynamic_action => p_dynamic_action
                                    )
                           );
            l_value := V( l_item_names(l_idx));
            apex_json.write('value'  , l_value);
            -- Thanks: Pavel Glebov (glebovpavel)
            apex_json.write
              ( 'display'
              , get_display_value
                  ( p_item_name => l_item_names(l_idx)
                  , p_value     => l_value
                  )
              );
            -- eof thanks

            apex_json.close_object;
        end loop;

        apex_json.close_array;
    end if;

    -- pass back the clob response
    if l_return_clob
    then
        apex_json.write('clob', apex_application.g_clob_01);
    end if;

    apex_json.write('status', 'success');

    l_message := nvl(apex_application.g_x01, l_success_message);

    if not l_replace_on_client
    then
        l_message := apex_plugin_util.replace_substitutions(l_message);
    end if;

    apex_json.write('message', l_message);

    if apex_application.g_x02 is not null
    then
        if not l_replace_on_client
        then
            l_message_title := apex_plugin_util.replace_substitutions(apex_application.g_x02);
        end if;
        apex_json.write('messageTitle', l_message_title);
    end if;

    if apex_application.g_x03 is not null
    then
        apex_json.write('messageType', trim(lower(apex_application.g_x03)));
    end if;

    -- the developer can cancel following actions
    apex_json.write('cancelActions', upper(apex_application.g_x04) IN ('CANCEL','STOP','TRUE'));

    -- the developer can fire an event if they desire
    apex_json.write('eventName', apex_application.g_x05);

    apex_json.close_object;

    return l_return;

exception
    when others then
        rollback;

        l_message := coalesce(apex_application.g_x01, l_error_message, sqlerrm);
        l_message := replace(l_message, '#SQLCODE#', escape_html(sqlcode, l_escape_message));
        l_message := replace(l_message, '#SQLERRM#', escape_html(sqlerrm, l_escape_message));
        l_message := replace(l_message, '#SQLERRM_TEXT#', escape_html(substr(sqlerrm, instr(sqlerrm, ':')+1), l_escape_message));

        apex_json.initialize_output;
        l_apex_error.message             := l_message;
        l_apex_error.ora_sqlcode         := sqlcode;
        l_apex_error.ora_sqlerrm         := sqlerrm;
        l_apex_error.error_backtrace     := dbms_utility.format_error_backtrace;

        l_result := error_function_callback(l_apex_error);

        apex_json.open_object;
        apex_json.write('status' , 'error');

        if not l_replace_on_client
        then
            l_message := apex_plugin_util.replace_substitutions(l_message);
        end if;

        apex_json.write('message'         , l_result.message);
        apex_json.write('additional_info' , l_result.additional_info);
        apex_json.write('display_location', l_result.display_location);
        apex_json.write('page_item_name'  , l_result.page_item_name);
        apex_json.write('column_alias'    , l_result.column_alias);

        if apex_application.g_x02 is not null
        then
            if not l_replace_on_client
            then
                l_message_title := apex_plugin_util.replace_substitutions(apex_application.g_x02);
            end if;
            apex_json.write('messageTitle', l_message_title);
        end if;

        apex_json.write('messageType', 'error');

        apex_json.close_object;

        return l_return;
end ajax;

end;
/


