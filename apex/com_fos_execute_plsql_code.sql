prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_190200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2019.10.04'
,p_release=>'19.2.0.00.18'
,p_default_workspace_id=>1620873114056663
,p_default_application_id=>102
,p_default_id_offset=>0
,p_default_owner=>'FOS_MASTER_WS'
);
end;
/

prompt APPLICATION 102 - FOS Dev - Plugin Master
--
-- Application Export:
--   Application:     102
--   Name:            FOS Dev - Plugin Master
--   Exported By:     FOS_MASTER_WS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 61118001090994374
--     PLUGIN: 134108205512926532
--     PLUGIN: 1039471776506160903
--     PLUGIN: 547902228942303344
--     PLUGIN: 217651153971039957
--     PLUGIN: 412155278231616931
--     PLUGIN: 1389837954374630576
--     PLUGIN: 461352325906078083
--     PLUGIN: 13235263798301758
--     PLUGIN: 216426771609128043
--     PLUGIN: 37441962356114799
--     PLUGIN: 1846579882179407086
--     PLUGIN: 8354320589762683
--     PLUGIN: 50031193176975232
--     PLUGIN: 106296184223956059
--     PLUGIN: 35822631205839510
--     PLUGIN: 2674568769566617
--     PLUGIN: 183507938916453268
--     PLUGIN: 14934236679644451
--     PLUGIN: 2600618193722136
--     PLUGIN: 2657630155025963
--     PLUGIN: 284978227819945411
--     PLUGIN: 56714461465893111
--     PLUGIN: 98648032013264649
--     PLUGIN: 455014954654760331
--     PLUGIN: 98504124924145200
--     PLUGIN: 212503470416800524
--   Manifest End
--   Version:         19.2.0.00.18
--   Instance ID:     250144500186934
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/com_fos_execute_plsql_code
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(1846579882179407086)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'COM.FOS.EXECUTE_PLSQL_CODE'
,p_display_name=>'FOS - Execute PL/SQL Code'
,p_category=>'EXECUTE'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_javascript_file_urls=>'#PLUGIN_FILES#js/script#MIN#.js'
,p_css_file_urls=>'#PLUGIN_FILES#css/style#MIN#.css'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- =============================================================================',
'--',
'--  FOS = FOEX Open Source (fos.world), by FOEX GmbH, Austria (www.foex.at)',
'--',
'--  This is an improved version of "Execute PL/SQL Code" dynamic action.',
'--',
'--  License: MIT',
'--',
'--  GitHub: https://github.com/foex-open-source/fos-execute-plsql-code',
'--',
'-- =============================================================================',
'g_in_error_handling_callback boolean := false;',
'',
'--------------------------------------------------------------------------------',
'-- private function to include the apex error handling function, if one is',
'-- defined on application or page level',
'--------------------------------------------------------------------------------',
'function error_function_callback',
'  ( p_error in apex_error.t_error',
'  )  return apex_error.t_error_result',
'is',
'    c_cr constant varchar2(1) := chr(10);',
'',
'    l_error_handling_function apex_application_pages.error_handling_function%type;',
'    l_statement               varchar2(32767);',
'    l_result                  apex_error.t_error_result;',
'',
'    procedure log_value',
'      ( p_attribute_name in varchar2',
'      , p_old_value      in varchar2',
'      , p_new_value      in varchar2 ',
'      )',
'    is',
'    begin',
'        if   p_old_value <> p_new_value',
'          or (p_old_value is not null and p_new_value is null)',
'          or (p_old_value is null     and p_new_value is not null)',
'        then',
'            apex_debug.info(''%s: %s'', p_attribute_name, p_new_value);',
'        end if;',
'    end log_value;',
'',
'begin',
'    if not g_in_error_handling_callback ',
'    then',
'        g_in_error_handling_callback := true;',
'',
'        begin',
'            select /*+ result_cache */',
'                   coalesce(p.error_handling_function, f.error_handling_function)',
'              into l_error_handling_function',
'              from apex_applications f,',
'                   apex_application_pages p',
'             where f.application_id     = apex_application.g_flow_id',
'               and p.application_id (+) = f.application_id',
'               and p.page_id        (+) = apex_application.g_flow_step_id;',
'        exception when no_data_found then',
'            null;',
'        end;',
'    end if;',
'',
'    if l_error_handling_function is not null',
'    then',
'        l_statement := ''declare''||c_cr||',
'                           ''l_error apex_error.t_error;''||c_cr||',
'                       ''begin''||c_cr||',
'                           ''l_error := apex_error.g_error;''||c_cr||',
'                           ''apex_error.g_error_result := ''||l_error_handling_function||'' (''||c_cr||',
'                               ''p_error => l_error );''||c_cr||',
'                       ''end;'';',
'',
'        apex_error.g_error := p_error;',
'',
'        begin',
'            apex_exec.execute_plsql(l_statement);',
'        exception when others then',
'            apex_debug.error(''error in error handler: %s'', sqlerrm);',
'            apex_debug.error(''backtrace: %s'', dbms_utility.format_error_backtrace);',
'        end;',
'',
'        l_result := apex_error.g_error_result;',
'',
'        if l_result.message is null',
'        then',
'            l_result.message          := nvl(l_result.message,          p_error.message);',
'            l_result.additional_info  := nvl(l_result.additional_info,  p_error.additional_info);',
'            l_result.display_location := nvl(l_result.display_location, p_error.display_location);',
'            l_result.page_item_name   := nvl(l_result.page_item_name,   p_error.page_item_name);',
'            l_result.column_alias     := nvl(l_result.column_alias,     p_error.column_alias);',
'        end if;',
'    else',
'        l_result.message          := p_error.message;',
'        l_result.additional_info  := p_error.additional_info;',
'        l_result.display_location := p_error.display_location;',
'        l_result.page_item_name   := p_error.page_item_name;',
'        l_result.column_alias     := p_error.column_alias;',
'    end if;',
'',
'    if l_result.message = l_result.additional_info',
'    then',
'        l_result.additional_info := null;',
'    end if;',
'',
'    g_in_error_handling_callback := false;',
'',
'    return l_result;',
'',
'exception',
'    when others then',
'        l_result.message             := ''custom apex error handling function failed !!'';',
'        l_result.additional_info     := null;',
'        l_result.display_location    := apex_error.c_on_error_page;',
'        l_result.page_item_name      := null;',
'        l_result.column_alias        := null;',
'        g_in_error_handling_callback := false;',
'        ',
'        return l_result;',
'end error_function_callback;',
'',
'--',
'-- Cater for display values',
'-- Thanks: Pavel Glebov (glebovpavel)',
'--',
'function get_display_value',
'  ( p_item_name in apex_application_page_items.item_name%type,',
'    p_value     in varchar2',
'  ) return varchar2',
'is',
'    l_display_as_code     apex_application_page_items.display_as_code%type; ',
'    l_lov_named_lov       apex_application_page_items.lov_named_lov%type; ',
'    l_lov_definition      apex_application_page_items.lov_definition%type;',
'    l_lov_display_null    apex_application_page_items.lov_display_null%type;',
'    l_lov_null_text       apex_application_page_items.lov_null_text%type;    ',
'    l_app_id              apex_application_page_items.application_id%type    := nv(''APP_ID'');',
'    l_page_id             apex_application_page_items.page_id%type           := nv(''APP_PAGE_ID'');',
'begin',
'    begin',
'        select display_as_code',
'             , lov_named_lov ',
'             , lov_definition',
'             , lov_display_null',
'             , lov_null_text',
'          into l_display_as_code',
'             , l_lov_named_lov',
'             , l_lov_definition',
'             , l_lov_display_null',
'             , l_lov_null_text',
'          from apex_application_page_items',
'         where application_id  = l_app_id',
'           and page_id        in (wwv_flow.g_global_page_id, l_page_id) -- Bug fix: added support for page zero items - thanks mbrde',
'           and item_name       = p_item_name',
'        ;',
'    exception',
'        when no_data_found then',
'            raise_application_error(-20001,''Item ''||p_item_name||'' not found!'');',
'    end;   ',
'    ',
'    if l_display_as_code != ''NATIVE_POPUP_LOV'' ',
'    then',
'        return '''';',
'    end if;  ',
'  ',
'    if l_lov_display_null = ''Yes'' ',
'    then',
'        null; ',
'    else ',
'        l_lov_null_text := '''';',
'    end if;    ',
'    ',
'    if l_lov_named_lov is not null ',
'    then ',
'        return apex_item.text_from_lov ',
'          ( p_value     => p_value',
'          , p_lov       => l_lov_named_lov',
'          , p_null_text => l_lov_null_text',
'          );',
'    else',
'        return apex_item.text_from_lov_query  ',
'          ( p_value     => p_value',
'          , p_query     => l_lov_definition',
'          , p_null_text => l_lov_null_text',
'          );',
'    end if;',
'end get_display_value;',
'',
'--------------------------------------------------------------------------------',
'-- this render function sets up a javascript function which will be called',
'-- when the dynamic action is executed.',
'-- all relevant configuration settings will be passed to this function as JSON',
'--------------------------------------------------------------------------------',
'function render',
'  ( p_dynamic_action apex_plugin.t_dynamic_action',
'  , p_plugin         apex_plugin.t_plugin',
'  )',
'return apex_plugin.t_dynamic_action_render_result',
'is',
'    -- l_result is necessary for the plugin infrastructure',
'    l_result                   apex_plugin.t_dynamic_action_render_result;',
'    ',
'    l_ajax_id                  varchar2(4000) := apex_plugin.get_ajax_identifier;',
'    ',
'    -- read plugin parameters and store in local variables',
'    l_items_to_submit          apex_t_varchar2 := apex_string.split(p_dynamic_action.attribute_02, '','');',
'    l_items_to_return          apex_t_varchar2 := apex_string.split(p_dynamic_action.attribute_03, '','');',
'    ',
'    l_submit_clob              p_dynamic_action.attribute_06%type := p_dynamic_action.attribute_06;',
'    l_submit_clob_item         p_dynamic_action.attribute_07%type := p_dynamic_action.attribute_07;',
'    l_submit_clob_variable     p_dynamic_action.attribute_08%type := p_dynamic_action.attribute_08;',
'    ',
'    l_return_clob              p_dynamic_action.attribute_09%type := p_dynamic_action.attribute_09;',
'    l_return_clob_item         p_dynamic_action.attribute_10%type := p_dynamic_action.attribute_10;',
'    l_return_clob_variable     p_dynamic_action.attribute_11%type := p_dynamic_action.attribute_11;',
'',
'    --extra options',
'    l_suppress_change_event    boolean := instr(p_dynamic_action.attribute_15, ''suppressChangeEvent'')  > 0;',
'    l_show_error_as_alert      boolean := instr(p_dynamic_action.attribute_15, ''showErrorAsAlert'')     > 0;',
'    l_show_spinner             boolean := instr(p_dynamic_action.attribute_15, ''showSpinner'')          > 0;',
'    l_show_spinner_overlay     boolean := instr(p_dynamic_action.attribute_15, ''showSpinnerOverlay'')   > 0;',
'    l_show_spinner_on_region   boolean := instr(p_dynamic_action.attribute_15, ''spinnerPosition'')      > 0;',
'    l_replace_on_client        boolean := instr(p_dynamic_action.attribute_15, ''client-substitutions'') > 0;',
'    l_escape_message           boolean := instr(p_dynamic_action.attribute_15, ''escape-message'')       > 0;',
'',
'    -- Javascript Initialization Code',
'    l_init_js_fn               varchar2(32767) := nvl(apex_plugin_util.replace_substitutions(p_dynamic_action.init_javascript_code), ''undefined'');',
'    ',
'begin',
'    -- standard debugging intro, but only if necessary',
'    if apex_application.g_debug and substr(:DEBUG,6) >= 6',
'    then',
'        apex_plugin_util.debug_dynamic_action',
'          ( p_plugin         => p_plugin',
'          , p_dynamic_action => p_dynamic_action',
'          );',
'    end if;',
'    ',
'    -- check if we need to add our toastr plugin library files',
'    apex_css.add_file ',
'      ( p_name           => apex_plugin_util.replace_substitutions(''fostr#MIN#.css'')',
'      , p_directory      => p_plugin.file_prefix || ''css/''',
'      , p_skip_extension => true',
'      , p_key            => ''fostr''',
'      );    ',
'    apex_javascript.add_library ',
'      ( p_name           => apex_plugin_util.replace_substitutions(''fostr#MIN#.js'')',
'      , p_directory      => p_plugin.file_prefix || ''js/''',
'      , p_skip_extension => true',
'      , p_key            => ''fostr''',
'      );    ',
'    ',
'    -- create a JS function call passing all settings as a JSON object',
'    --',
'    -- FOS.execPlSql.executePlSqlCode(this, {',
'    --     "ajaxId": "SDtjkD9_TUyDJZzOzlRKnFkZWTFWkOqJrwNuJyUzooI",',
'    --     "pageItems": {},',
'    --     "clobSettings": {',
'    --         "submitClob": false,',
'    --         "returnClob": false',
'    --     },',
'    --     "options": {',
'    --         "suppressChangeEvent": false,',
'    --         "showErrorAsAlert": true',
'    --     }',
'    -- });',
'    apex_json.initialize_clob_output;',
'    apex_json.open_object;',
'',
'    apex_json.write(''ajaxId''             , l_ajax_id);',
'    ',
'    apex_json.open_object(''pageItems'');',
'    apex_json.write(''itemsToSubmit''      , l_items_to_submit);',
'    apex_json.write(''itemsToReturn''      , l_items_to_return);',
'    apex_json.close_object;',
'',
'    apex_json.open_object(''spinnerSettings'');',
'    apex_json.write(''showSpinner''        , l_show_spinner);',
'    apex_json.write(''showSpinnerOverlay'' , l_show_spinner_overlay);',
'    apex_json.write(''showSpinnerOnRegion'', l_show_spinner_on_region);',
'    apex_json.close_object;',
'',
'    apex_json.open_object(''clobSettings'');',
'    apex_json.write(''submitClob''         , l_submit_clob is not null);',
'    apex_json.write(''submitClobFrom''     , l_submit_clob);',
'    apex_json.write(''submitClobItem''     , l_submit_clob_item);',
'    apex_json.write(''submitClobVariable'' , l_submit_clob_variable);',
'    apex_json.write(''returnClob''         , l_return_clob is not null);',
'    apex_json.write(''returnClobInto''     , l_return_clob);',
'    apex_json.write(''returnClobItem''     , l_return_clob_item);',
'    apex_json.write(''returnClobVariable'' , l_return_clob_variable);',
'    apex_json.close_object;',
'',
'    apex_json.open_object(''options'');',
'    apex_json.write(''suppressChangeEvent'' , l_suppress_change_event);',
'    apex_json.write(''showErrorAsAlert''    , l_show_error_as_alert);',
'    apex_json.write(''performSubstitutions'', l_replace_on_client);',
'    apex_json.write(''escapeMessage''       , l_escape_message);',
'    apex_json.close_object;',
'',
'    apex_json.close_object;',
'    l_result.javascript_function := ''function(){FOS.exec.plsql(this, ''|| apex_json.get_clob_output || '', ''|| l_init_js_fn ||'');}'';',
'    ',
'    apex_json.free_output;',
'',
'    -- all done, return l_result now containing the javascript function',
'    return l_result;',
'end render;',
'',
'--------------------------------------------------------------------------------',
'-- the ajax function is invoked from the clientside dynamic action to execute',
'-- the configured pl/sql code.',
'-- page items and a clob can be passend into this function, it is also able to',
'-- return new item values and clob output.',
'-- clob values passed in (clob to submit) is accessible as apex_application.g_clob_01',
'--------------------------------------------------------------------------------',
'function ajax',
'  ( p_dynamic_action apex_plugin.t_dynamic_action',
'  , p_plugin         apex_plugin.t_plugin',
'  )',
'return apex_plugin.t_dynamic_action_ajax_result',
'is',
'    -- error handling',
'    l_apex_error       apex_error.t_error;',
'    l_result           apex_error.t_error_result;',
'    -- return type which is necessary for the plugin infrastructure',
'    l_return           apex_plugin.t_dynamic_action_ajax_result;',
'    ',
'    -- read plugin parameters and store in local variables',
'    l_statement         p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;',
'    l_items_to_return   p_dynamic_action.attribute_03%type := p_dynamic_action.attribute_03;',
'    l_success_message   p_dynamic_action.attribute_04%type := p_dynamic_action.attribute_04;',
'    l_error_message     p_dynamic_action.attribute_05%type := p_dynamic_action.attribute_05;',
'    l_return_clob       boolean                            := p_dynamic_action.attribute_09 is not null;',
'    ',
'    l_escape_message    boolean := instr(p_dynamic_action.attribute_15, ''escape-message'')       > 0;    ',
'    l_replace_on_client boolean := instr(p_dynamic_action.attribute_15, ''client-substitutions'') > 0;',
'    ',
'    l_message          varchar2(32767);',
'    l_message_title    varchar2(32767);',
'    l_item_names       apex_t_varchar2;',
'    l_value            varchar2(32767);',
'',
'    --',
'    -- We won''t escape serverside if we do it client side to avoid double escaping',
'    --',
'    function escape_html',
'      ( p_html                   in varchar2',
'      , p_escape_already_enabled in boolean',
'      ) return varchar2',
'    is ',
'    begin',
'        return case when p_escape_already_enabled then p_html else apex_escape.html(p_html) end;',
'    end escape_html;',
'',
'begin',
'    -- standard debugging intro, but only if necessary',
'    if apex_application.g_debug and substr(:DEBUG,6) >= 6',
'    then',
'        apex_plugin_util.debug_dynamic_action',
'          ( p_plugin         => p_plugin',
'          , p_dynamic_action => p_dynamic_action',
'          );',
'    end if;',
'    ',
'    ----------------------------------------------------------------------------',
'    -- this now runs the actual PL/SQL code',
'    ----------------------------------------------------------------------------',
'    apex_exec.execute_plsql(p_plsql_code => l_statement);',
'',
'    -- prepare a json object as response for the client',
'    apex_json.initialize_output;',
'    apex_json.open_object;',
'',
'    -- add return items+values to json',
'    if l_items_to_return is not null ',
'    then',
'        l_item_names := apex_string.split(l_items_to_return, '','');',
'        ',
'        apex_json.open_array(''items'');',
'        ',
'        for l_idx in 1 .. l_item_names.count ',
'        loop',
'            apex_json.open_object;',
'            apex_json.write(''id'', apex_plugin_util.item_names_to_dom',
'                                    ( p_item_names     => l_item_names(l_idx)',
'                                    , p_dynamic_action => p_dynamic_action',
'                                    )',
'                           );',
'            l_value := V( l_item_names(l_idx));    ',
'            apex_json.write(''value''  , l_value);',
'            -- Thanks: Pavel Glebov (glebovpavel)',
'            apex_json.write',
'              ( ''display''',
'              , get_display_value',
'                  ( p_item_name => l_item_names(l_idx)',
'                  , p_value     => l_value',
'                  )',
'              );',
'            -- eof thanks',
'',
'            apex_json.close_object;',
'        end loop;',
'',
'        apex_json.close_array;',
'    end if;',
'    ',
'    -- pass back the clob response',
'    if l_return_clob ',
'    then',
'        apex_json.write(''clob'', apex_application.g_clob_01);',
'    end if;',
'    ',
'    apex_json.write(''status'', ''success'');',
'    ',
'    l_message := nvl(apex_application.g_x01, l_success_message);',
'',
'    if not l_replace_on_client ',
'    then',
'        l_message := apex_plugin_util.replace_substitutions(l_message);',
'    end if;',
'',
'    apex_json.write(''message'', l_message);',
'    ',
'    if apex_application.g_x02 is not null ',
'    then',
'        if not l_replace_on_client ',
'        then',
'            l_message_title := apex_plugin_util.replace_substitutions(apex_application.g_x02);',
'        end if;',
'        apex_json.write(''messageTitle'', l_message_title);',
'    end if;',
'',
'    if apex_application.g_x03 is not null ',
'    then',
'        apex_json.write(''messageType'', trim(lower(apex_application.g_x03)));',
'    end if;',
'    ',
'    -- the developer can cancel following actions',
'    apex_json.write(''cancelActions'', upper(apex_application.g_x04) IN (''CANCEL'',''STOP'',''TRUE''));',
'    ',
'    -- the developer can fire an event if they desire',
'    apex_json.write(''eventName'', apex_application.g_x05);',
'',
'    apex_json.close_object;',
'',
'    return l_return;',
'',
'exception',
'    when others then',
'        rollback;',
'',
'        l_message := coalesce(apex_application.g_x01, l_error_message, sqlerrm);',
'        l_message := replace(l_message, ''#SQLCODE#'', escape_html(sqlcode, l_escape_message));',
'        l_message := replace(l_message, ''#SQLERRM#'', escape_html(sqlerrm, l_escape_message));',
'        l_message := replace(l_message, ''#SQLERRM_TEXT#'', escape_html(substr(sqlerrm, instr(sqlerrm, '':'')+1), l_escape_message));',
'',
'        apex_json.initialize_output;',
'        l_apex_error.message             := l_message;',
'        l_apex_error.ora_sqlcode         := sqlcode;',
'        l_apex_error.ora_sqlerrm         := sqlerrm;',
'        l_apex_error.error_backtrace     := dbms_utility.format_error_backtrace;',
'',
'        l_result := error_function_callback(l_apex_error);',
'',
'        apex_json.open_object;',
'        apex_json.write(''status'' , ''error'');',
'',
'        if not l_replace_on_client ',
'        then',
'            l_message := apex_plugin_util.replace_substitutions(l_message);',
'        end if;',
'',
'        apex_json.write(''message''         , l_result.message);',
'        apex_json.write(''additional_info'' , l_result.additional_info);',
'        apex_json.write(''display_location'', l_result.display_location);',
'        apex_json.write(''page_item_name''  , l_result.page_item_name);',
'        apex_json.write(''column_alias''    , l_result.column_alias);',
'',
'        if apex_application.g_x02 is not null ',
'        then',
'            if not l_replace_on_client ',
'            then',
'                l_message_title := apex_plugin_util.replace_substitutions(apex_application.g_x02);',
'            end if;',
'            apex_json.write(''messageTitle'', l_message_title);',
'        end if;',
'',
'        apex_json.write(''messageType'', ''error'');',
'        ',
'        apex_json.close_object;',
'',
'        return l_return;',
'end ajax;'))
,p_api_version=>1
,p_render_function=>'render'
,p_ajax_function=>'ajax'
,p_standard_attributes=>'REGION:JQUERY_SELECTOR:TRIGGERING_ELEMENT:STOP_EXECUTION_ON_ERROR:WAIT_FOR_RESULT:INIT_JAVASCRIPT_CODE'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>The <strong>FOS - Execute PL/SQL Code</strong> dynamic action plug-in introduces some enhancements to the existing "Execute PL/SQL Code" dynamic action that APEX provides. These additional features include:</p>',
'<ol>',
'<li>Providing a processing icon whilst optionally masking the background either at the region or page level</li>',
'<li>Declarative Success & Error Notifications</li>',
'<li>Submitting and returning CLOB data using page items or Javascript variables</li>',
'<li>Returning the execution results to a Javascript variable</li>',
'<li>Optionally suppressing the change event on page item values that are returned</li>',
'</ol>'))
,p_version_identifier=>'22.1.0'
,p_about_url=>'https://fos.world'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'// Settings for the FOS browser extension',
'@fos-auto-return-to-page',
'@fos-auto-open-files:js/script.js'))
,p_files_version=>657
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(1846580793177429162)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'PL/SQL Code'
,p_attribute_type=>'PLSQL'
,p_is_required=>true
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<pre>',
'begin',
'    setCommission(:P1_SAL, :P1_JOB);',
'end;',
'</pre>',
'<p>In this example, you need to enter <code>P1_SAL,P1_JOB</code> in <strong>Page Items to Submit</strong>.</p>',
'<h3>Notifications</h3>',
'<p>You can override the success notification using the following global variables:</p>',
'<pre>',
'apex_application.g_x01 := ''My custom message'';',
'apex_application.g_x02 := ''My custom title''; -- optional',
'apex_application.g_x03 := ''warning'';         -- optional (success, info, warning, error)',
'</pre>'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Specify an execution only PL/SQL anonymous block, that is executed on the server.</p>',
'<p>You can reference other page or application items from within your application using bind syntax (for example <code>:P1_MY_ITEM</code>). Any items referenced also need to be included in <strong>Page Items to Submit</strong>.</p>',
'<p>Reference CLOB value using <strong>apex_application.g_clob_01</strong>.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(1846581395039439217)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Items to Submit'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Enter the uppercase page items submitted to the server, and therefore, available for use within your <strong>PL/SQL Code</strong>.</p>',
'<p>You can type in the item name or pick from the list of available items.',
'If you pick from the list and there is already text entered then a comma is placed at the end of the existing text, followed by the item name returned from the list.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(923136681286664516)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Items to Return'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<pre>',
'    apex_util.set_session_state(''P1_MY_ITEM'', ''New Value'');',
'</pre>',
'</p>',
'<p>In this example, enter <code>P1_MY_ITEM</code> in this attribute in order for ''New Value'' to be displayed in that item on your page.</p>'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Enter the uppercase page items set when the call to the server returns, based on their current value in session state. If your <strong>PL/SQL Code</strong> sets one or more page item values in session state you need to define those items in this a'
||'ttribute.</p>',
'<p>You can type in the item name or pick from the list of available items.',
'If you pick from the list and there is already text entered then a comma is placed at the end of the existing text, followed by the item name returned from the list.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(25734763098615211)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Success Message'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>true
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<h3>Notifications</h3>',
'<p>You can override the success notification using the following global variables:</p>',
'<pre>',
'apex_application.g_x01 := ''My custom message'';',
'apex_application.g_x02 := ''My custom title''; -- optional',
'apex_application.g_x03 := ''warning'';         -- optional (success, info, warning, error)',
'</pre>'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Provide a success message which will be displayed as a green alert if the execution is completed successfully.</p>',
'<p>This message can be dynamically overridden in the PL/SQL Code block by assigning the new value to the apex_application.g_x01 global variable.</p>',
'<pre>apex_application.g_x01 := ''New Success Message'';</pre>',
'<p>If no success message is provided, the notification will not be shown.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(25740704451616721)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Error Message'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'#SQLERRM#'
,p_is_translatable=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Provide an error message which will be displayed as a warning notification if the execution is completed unsuccessfully.</p>',

'<p>This message can be dynamically overridden in the PL/SQL Code block by assigning the new value to the <code>apex_application.g_x02</code> global variable.</p>',
'<pre>apex_application.g_x02 := ''New Error Message'';</pre>',
'<p>If no error message is provided, none will be shown.</p>',
'<p>You can also use the #SQLCODE#, #SQLERRM# and #SQLERRM_TEXT# substitution strings for more detailed error information.</p>',
'<p>By default the error message will be displayed in the top right corner as a notification. If you wish to display it as an alert, tick the Show "Error as Alert" checkbox.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(25850441847216115)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Submit CLOB'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_null_text=>'No'
,p_help_text=>'<p>Values submitted to the server in APEX page items can have a maximum length of 4000 characters. If you need to submit values larger than that, specify here the source, and the value will be made available to you via the <code>apex_application.g_cl'
||'ob_01</code> global variable in your PL/SQL code block. From there, you can modify the value, store it in a table or collection, etc.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(25856346218226854)
,p_plugin_attribute_id=>wwv_flow_api.id(25850441847216115)
,p_display_sequence=>10
,p_display_value=>'From Page Item'
,p_return_value=>'pageitem'
,p_help_text=>'CLOB will be read from a page item<br>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(25856819775231278)
,p_plugin_attribute_id=>wwv_flow_api.id(25850441847216115)
,p_display_sequence=>20
,p_display_value=>'From JavaScript Variable'
,p_return_value=>'javascriptvariable'
,p_help_text=>'CLOB will be read from a javascript variable. <strong>The variable must be accessible on the window object.</strong><br>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(147170584288857908)
,p_plugin_attribute_id=>wwv_flow_api.id(25850441847216115)
,p_display_sequence=>30
,p_display_value=>'From Function Defined in "Javascript Initialization Code"'
,p_return_value=>'javascriptinit'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>You can define a function in the "Javascript Initialization Code" attribute named "submitClob" that returns your value e.g.</p>',
'<pre>',
'function(options) {',
'   options.submitClob = function() { return getMyClobValue(); }',
'   return options;',
'}',
'</pre>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(25862662478296030)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Submit From'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(25850441847216115)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'pageitem'
,p_help_text=>'<p>Specify the page item whose value will be loaded into the <code>apex_application.g_clob_01</code> global variable.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(25868572942300749)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Submit From'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(25850441847216115)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'javascriptvariable'
,p_examples=>'<pre>nameSpace.largeString</pre>'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Specify the name of the JavaScript variable to be loaded into the <code>apex_application.g_clob_01</code> global variable.</p>',
'<p>If the variable is a JSON, it will be stringified.</p>',
'<p>You do not have to prefix the variable with <code>window.</code></p>'))
);
end;
/
begin
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(25880250916306983)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_prompt=>'Return CLOB'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_null_text=>'No'
,p_help_text=>'<p>If you set this option to anything other that "No", any content found in <code>apex_application.g_clob_01</code> at the end of the PL/SQL execution will be loaded in the specified destination.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(25886216736310169)
,p_plugin_attribute_id=>wwv_flow_api.id(25880250916306983)
,p_display_sequence=>10
,p_display_value=>'Into Page Item'
,p_return_value=>'pageitem'
,p_help_text=>'Receive CLOB and store in a page item<br>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(25886582543315830)
,p_plugin_attribute_id=>wwv_flow_api.id(25880250916306983)
,p_display_sequence=>20
,p_display_value=>'Into JavaScript Variable'
,p_return_value=>'javascriptvariable'
,p_help_text=>'Store CLOB in a javascript variable<br>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(25886996664317732)
,p_plugin_attribute_id=>wwv_flow_api.id(25880250916306983)
,p_display_sequence=>30
,p_display_value=>'Into JavaScript Variable as JSON'
,p_return_value=>'javascriptvariablejson'
,p_help_text=>'Store CLOB in a javascript variable, but have the CLOB parsed as JSON first, so javascript variable will hold an object, not a string.<br>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(147174168149749075)
,p_plugin_attribute_id=>wwv_flow_api.id(25880250916306983)
,p_display_sequence=>40
,p_display_value=>'Into Function Defined in "Javascript Initialization Code" as JSON'
,p_return_value=>'javascriptinitasjson'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>You can define a function in the "Javascript Initialization Code" attribute named "clobCallback" that takes the result and passes it in as the first argument of your Javascript function e.g.</p>',
'<pre>',
'function(options) {',
'   options.clobCallback = function(result) {',
'      if (result.status) {',
'         doSomeAction(result.value);',
'      } else {',
'         doSomeOtherAction(result.value)',
'      }',
'   }',
'   return options;',
'}',
'</pre>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(25887387211324940)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>100
,p_prompt=>'Return Into'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(25880250916306983)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'pageitem'
,p_help_text=>'<p>Specify a page item into which the value of <code>apex_application.g_clob_01</code> will be loaded.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(25893262072330782)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>11
,p_display_sequence=>110
,p_prompt=>'Return Into'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(25880250916306983)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'javascriptvariable,javascriptvariablejson'
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p><b>PL/SQL Code</b></p>',
'<pre>',
'apex_json.initialize_clob_output;',
'apex_json.open_array;',
'',
'for employee in (select * from emp)',
'loop',
'    apex_json.open_object;',
'    apex_json.write(''empno'', employee.empno);',
'    apex_json.write(''empname'', employee.empname);',
'    apex_json.close_object;',
'end loop;',
'',
'apex_json.close_array;',
'apex_application.g_clob_01 := apex_json.get_clob_output;',
'apex_json.free_output;',
'</pre>',
'<p><b>Return CLOB</b></p>',
'<pre>Into JavaScript Variable as JSON</pre>',
'<p><b>Return Into</b></p>',
'<pre>myApp.employees</pre>',
'',
'<p>You can then reference this object in any JavaScript context on the page, usually in subsequent Execute Javascript dynamic actions.</p>'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Specify the JavaScript variable into which the value of <code>apex_application.g_clob_01</code> will be loaded.</p>',
'<p>If you chose <b>Into JavaScript Variable</b> the value will simply be loaded as a string.</p>',
'<p>If you chose <b>Into JavaScript Variable as JSON</b> the value will be first parsed as JSON, then assigned to the variable.</p>',
'<p>Note that you can specify any variable, even a nested one. If it doesn''t exist, it will be created.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(25688942823733727)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>15
,p_display_sequence=>150
,p_prompt=>'Extra Options'
,p_attribute_type=>'CHECKBOXES'
,p_is_required=>false
,p_default_value=>'escape-message'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Fine control on behavior of the plug-in.<br>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(25694479033736372)
,p_plugin_attribute_id=>wwv_flow_api.id(25688942823733727)
,p_display_sequence=>10
,p_display_value=>'Suppress Change Event'
,p_return_value=>'suppressChangeEvent'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Specify whether the change event is suppressed on the items specified',
' in Page Items to Return. This prevents subsequent Change based Dynamic ',
'Actions from firing, for these items.</p>'))
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(25700005476750803)
,p_plugin_attribute_id=>wwv_flow_api.id(25688942823733727)
,p_display_sequence=>20
,p_display_value=>'Show Error as Alert'
,p_return_value=>'showErrorAsAlert'
,p_help_text=>'<p>By default, errors will be shown via <code>apex.message.showErrors</code> as opposed to <code>apex.message.alert</code>. If you wish to use the classic alert, tick this checkbox.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(26911967359337524)
,p_plugin_attribute_id=>wwv_flow_api.id(25688942823733727)
,p_display_sequence=>30
,p_display_value=>'Show Spinner/Processing Icon'
,p_return_value=>'showSpinner'
,p_help_text=>'<p>Check this option if you want to have a Spinner/Processing Icon to be displayed while waiting the execution to complete.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(26912322282349698)
,p_plugin_attribute_id=>wwv_flow_api.id(25688942823733727)
,p_display_sequence=>40
,p_display_value=>'Show Spinner with Modal Overlay Mask'
,p_return_value=>'showSpinnerOverlay'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Shows the spinner with a modal overlay stopping the user from interacting with the content behind the overlay mask.</p>',
'<p><strong>Note:</strong> this setting has no effect if you do not check "Show Spinner"</p>'))
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(26912767031366967)
,p_plugin_attribute_id=>wwv_flow_api.id(25688942823733727)
,p_display_sequence=>50
,p_display_value=>'Show Spinner on Region'
,p_return_value=>'spinnerPosition'
,p_help_text=>'<p>Check this option to only show the spinner on a particular region. If you do not check this option then it will be shown at the page level. If you have also checked the "Show Spinner Overlay Mask" it will only mask the region you have defined in t'
||'he "Affected Elements".</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(26908226083124205)
,p_plugin_attribute_id=>wwv_flow_api.id(25688942823733727)
,p_display_sequence=>100
,p_display_value=>'[Advanced] Result is JSON'
,p_return_value=>'jsonResult'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>You can return a JSON object as the response giving you the ability to perform the following:</p>',
'<ol>',
'<li>Success Message</li>',
'<li>Error Message</li>',
'<li>Add errors to page items</li>',
'<li>Hide/Show Page Items & Regions & Buttons</li>',
'<li>Disable/Enable Buttons</li>',
'<li>Set Items/Regions Read Only</li>',
'<li>Return page item values</li>',
'<li>Refresh Regions and Page (LOV) Items</li>',
'<li>Trigger Events</li>',
'<li>Add/Remove CSS Classes</li>',
'<li>Set Focus</li>',
'</ol>',
'<h3>Example JSON Structure</h3>',
'<pre>',
'{',
'   "success": true,',
'   "message": "",',
'   "clearErrors": true,',
'   "successMessage": "",',
'   "errorMessage": "",',
'   "itemErrors": {',
'      "P1_ITEM": "Example error message",',
'      "P1_ITEM2": "Other example message"',
'   },',
'   "hide": [{',
'         "type": "item",',
'         "name": "P1_ITEM1"',
'      },',
'      {',
'         "type": "region",',
'         "name": "IG_REPORT1"',
'      },',
'      {',
'         "type": "button",',
'         "name": "BTN1"',
'      },',
'      {',
'         "type": "column",',
'         "region": "",',
'         "name": "COLUMN1"',
'      }',
'   ],',
'   "show": [{',
'         "type": "item",',
'         "name": "P1_ITEM1"',
'      },',
'      {',
'         "type": "regon",',
'         "name": "IG_REPORT1"',
'      }',
'   ],',
'   "readOnly": [{',
'         "type": "item",',
'         "name": "P1_ITEM1"',
'      },',
'      {',
'         "type": "region",',
'         "name": "IG_REPORT1"',
'      }',
'   ],',
'   "setValues": [{',
'      "type": "item",',
'      "name": "P1_ITEM1",',
'      "value": "New Value"',
'   }],',
'   "refresh": [{',
'      "type": "item",',
'      "name": "P1_LOV1"',
'   }, {',
'      "type": "region",',
'      "name": "IG_REPORT1"',
'   }],',
'   "events": [{',
'      "selector": "body",',
'      "name": "my-custom-event1",',
'      "data": {}',
'   }, {',
'      "selector": "body",',
'      "name": "my-custom-event2",',
'      "data": {}',
'   }]',
'}',
'</pre>'))
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(40758752004890267)
,p_plugin_attribute_id=>wwv_flow_api.id(25688942823733727)
,p_display_sequence=>120
,p_display_value=>'Replace Message Substitutions Client-side'
,p_return_value=>'client-substitutions'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>By default, item substitutions in success and error messages will be performed server-side, with session-state values, right after the processing has finished in the AJAX call.</p>',
'<p>This option enables you to override this, and perform the substitutions on the client, after the AJAX response has arrived, but before the notification is shown.</p>',
'',
'<p>Server-side substitutions are usually the desired method, as they are sure to use the latest session-state values, but can also replace application items, which the client does not have access to. Client-side substitutions are desired when substit'
||'uting for an item whose value exists on the client, but has not yet propagated to session-state.</p>'))
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(40759133773893225)
,p_plugin_attribute_id=>wwv_flow_api.id(25688942823733727)
,p_display_sequence=>130
,p_display_value=>'Escape Special Characters in Messages'
,p_return_value=>'escape-message'
,p_help_text=>'<p>Enable this option to escape any HTML tags in the success or error message. This should remain turned on by default to avoid any possibility of a cross-site-scripting attack. If however you do need to display HTML in a notification, you can turn t'
||'his setting off, but escape individual page items via the <code>&P1_ITEM!HTML.</code> syntax.</p>'
);
wwv_flow_api.create_plugin_std_attribute(
 p_id=>wwv_flow_api.id(26907569718075119)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_name=>'INIT_JAVASCRIPT_CODE'
,p_is_required=>false
,p_depending_on_has_to_exist=>true
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<h3>Anonymous function</h3>',
'<p>When you define a function like the following it will only be applied to this plug-in instance:',
'<pre>',
'function (options, fostrOptions) {',
'   // top positions: top-left, top-center, top-right',
'   fostrOptions.position = ''top-left'';',
'   fostrOptions.escapeHtml = true;',
'   fostrOptions.dismissAfter = 10000;',
'}',
'</pre>',
'<h3>Getting & Returning JSON directly into a Javascript Function</h3>',
'<p>From v21.1 onwards we have introduced the capability to get your CLOB data directly from a javascript function, and return the JSON result directly back into a callback function e.g.</p>',
'<pre>',
'function(options) {',
'    var itemName = "P1020_MESSAGE";',
'    options.submitClob = function() {',
'        return JSON.stringify({',
'            message: $v(itemName)',
'        });',
'    };',
'    options.clobCallback = function(data) {',
'        apex.message.showPageSuccess(data.message);',
'    };',
'    return options;',
'}',
'</pre>',
'<h3>Centralized function</h3>',
'<p>You can re-use a function across all plug-in occurrences by using a named one i.e. you would add the following code in this "Javascript Initialization Code" attribute: </p>',
'<pre>myApp.execPlsqlConfigFn</pre>',
'<p>Then in the "Static Application File" you would define your function something like this:</p>',
'<pre>',
'window.myApp = window.myApp || {};',
'window.myApp.execPlsqlConfigFn = function (options, fostrOptions) {',
'   // top positions: top-left, top-center, top-right',
'   fostrOptions.position = ''top-left'';',
'   fostrOptions.escapeHtml = true;',
'   fostrOptions.dismissAfter = 10000;',
'}',
'</pre>'))
,p_help_text=>'<p>You can use this attribute to define a function that will allow you to change/override the plugin settings. This gives you added flexibility of controlling the settings from a single Javascript function defined in an "Static Application File"</p>'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A20676C6F62616C7320617065782C666F7374722C242C2473202A2F0A0A76617220464F53203D2077696E646F772E464F53207C7C207B7D3B0A464F532E65786563203D20464F532E65786563207C7C207B7D3B0A0A2F2A2A0A202A204275696C6473';
wwv_flow_api.g_varchar2_table(2) := '2061206E6573746564206F626A65637420696620697420646F65736E277420657869737420616E642061737369676E7320697420612076616C75650A202A0A202A2040706172616D207B6F626A6563747D2020206F626A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(3) := '616E206F626A6563740A202A2040706172616D207B737472696E677D2020206B657950617468202020202020202020706174682065787072657373696F6E207769746820222E2220617320736570617261746F720A202A2040706172616D207B73747269';
wwv_flow_api.g_varchar2_table(4) := '6E677D20202076616C756520202020202020202020207468652076616C756520746F20626520736574206174206B65795061746820696E206F626A0A202A2F0A464F532E657865632E6372656174654E65737465644F626A656374416E6441737369676E';
wwv_flow_api.g_varchar2_table(5) := '203D2066756E6374696F6E20286F626A2C206B6579506174682C2076616C756529207B0A20202020766172206B657950617468417272203D206B6579506174682E73706C697428272E27293B0A20202020766172206C6173744B6579496E646578203D20';
wwv_flow_api.g_varchar2_table(6) := '6B6579506174684172722E6C656E677468202D20313B0A20202020766172206B65793B0A20202020666F7220287661722069203D20303B2069203C206C6173744B6579496E6465783B202B2B6929207B0A20202020202020206B6579203D206B65795061';
wwv_flow_api.g_varchar2_table(7) := '74684172725B695D3B0A20202020202020206966202821286B657920696E206F626A2929207B0A2020202020202020202020206F626A5B6B65795D203D207B7D3B0A20202020202020207D0A20202020202020206F626A203D206F626A5B6B65795D3B0A';
wwv_flow_api.g_varchar2_table(8) := '202020207D0A202020206F626A5B6B6579506174684172725B6C6173744B6579496E6465785D5D203D2076616C75653B0A7D3B0A0A2F2A2A0A202A20546869732066756E6374696F6E20696D706C656D656E7473207468652064796E616D696320616374';
wwv_flow_api.g_varchar2_table(9) := '696F6E20616E642072756E732074686520636F6E6669677572656420706C2F73716C20636F646520696E207468652064617461626173652E0A202A20497420616C736F2074616B65732063617265206F662070617373696E67206974656D73206261636B';
wwv_flow_api.g_varchar2_table(10) := '20616E6420666F7274682C2073686F77696E67207370696E6E6572732C2068616E646C696E6720636C6F62732E0A202A0A202A2040706172616D207B6F626A6563747D2020206461436F6E74657874202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(11) := '202020202020202020202044796E616D696320416374696F6E20636F6E746578742061732070617373656420696E20627920415045580A202A2040706172616D207B6F626A6563747D202020636F6E666967202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(12) := '2020202020202020202020202020202020436F6E66696775726174696F6E206F626A65637420686F6C64696E67207468652073657474696E6773206F66207468652064796E616D696320616374696F6E0A202A2040706172616D207B737472696E677D20';
wwv_flow_api.g_varchar2_table(13) := '2020636F6E6669672E616A61784964202020202020202020202020202020202020202020202020202020204964656E746966696572206E656365737361727920666F72204150455820616A617820636F6D6D756E69636174696F6E2E2057696C6C206265';
wwv_flow_api.g_varchar2_table(14) := '2070617373656420746F20617065782E7365727665722E706C7567696E0A202A2040706172616D207B6F626A6563747D202020636F6E6669672E706167654974656D73202020202020202020202020202020202020202020202020204F626A6563742068';
wwv_flow_api.g_varchar2_table(15) := '6F6C64696E6720696E666F726D6174696F6E2061626F7574206974656D7320746F206265207375626D697474656420616E642072657475726E65640A202A2040706172616D207B737472696E677D202020636F6E6669672E706167654974656D732E6974';
wwv_flow_api.g_varchar2_table(16) := '656D73546F5375626D697420202020202020202020204C697374206F662070616765206974656D73206E656564656420746F2062652070617373656420776974682074686520616A61782063616C6C0A202A2040706172616D207B737472696E677D2020';
wwv_flow_api.g_varchar2_table(17) := '20636F6E6669672E706167654974656D732E6974656D73546F52657475726E20202020202020202020204C697374206F662070616765206974656D73206E656564656420746F2062652072657475726E65642066726F6D2074686520616A61782063616C';
wwv_flow_api.g_varchar2_table(18) := '6C0A202A2040706172616D207B6F626A6563747D202020636F6E6669672E636C6F6253657474696E6773202020202020202020202020202020202020202020204F626A65637420686F6C64696E6720636F6E66696775726174696F6E206F6620636C6F62';
wwv_flow_api.g_varchar2_table(19) := '20696E666F20746F206265207375626D697474656420616E642072657475726E65640A202A2040706172616D207B626F6F6C65616E7D2020636F6E6669672E636C6F6253657474696E67732E7375626D6974436C6F622020202020202020202020576865';
wwv_flow_api.g_varchar2_table(20) := '74686572206120636C6F62206E6565647320746F206265207375626D697474656420696E746F2074686520616A61782063616C6C0A202A2040706172616D207B737472696E677D2020205B636F6E6669672E636C6F6253657474696E67732E7375626D69';
wwv_flow_api.g_varchar2_table(21) := '74436C6F6246726F6D5D2020202020496E64696361746F722069662074686520636C6F622069732074616B656E2066726F6D20612070616765206974656D206F722061206A73207661726961626C650A202A2040706172616D207B737472696E677D2020';
wwv_flow_api.g_varchar2_table(22) := '205B636F6E6669672E636C6F6253657474696E67732E7375626D6974436C6F624974656D5D20202020204E616D65206F6620612070616765206974656D2074686520636C6F6220697320726561642066726F6D0A202A2040706172616D207B737472696E';
wwv_flow_api.g_varchar2_table(23) := '677D2020205B636F6E6669672E636C6F6253657474696E67732E7375626D6974436C6F625661726961626C655D204E616D65206F662061206A617661736372697074207661726961626C652074686520636C6F6220697320726561642066726F6D0A202A';
wwv_flow_api.g_varchar2_table(24) := '2040706172616D207B626F6F6C65616E7D2020636F6E6669672E636C6F6253657474696E67732E72657475726E436C6F62202020202020202020202057686574686572206120636C6F62206E6565647320746F2062652072657475726E65642066726F6D';
wwv_flow_api.g_varchar2_table(25) := '2074686520616A61782063616C6C0A202A2040706172616D207B737472696E677D2020205B636F6E6669672E636C6F6253657474696E67732E72657475726E436C6F6246726F6D5D2020202020496E64696361746F722069662074686520636C6F622069';
wwv_flow_api.g_varchar2_table(26) := '732072657475726E656420746F20612070616765206974656D206F722061206A73207661726961626C650A202A2040706172616D207B737472696E677D2020205B636F6E6669672E636C6F6253657474696E67732E72657475726E436C6F624974656D5D';
wwv_flow_api.g_varchar2_table(27) := '20202020204E616D65206F6620612070616765206974656D2074686520636C6F622069732072657475726E656420746F0A202A2040706172616D207B737472696E677D2020205B636F6E6669672E636C6F6253657474696E67732E72657475726E436C6F';
wwv_flow_api.g_varchar2_table(28) := '625661726961626C655D204E616D65206F662061206A617661736372697074207661726961626C652074686520636C6F622069732072657475726E656420746F0A202A2040706172616D207B6F626A6563747D202020636F6E6669672E6F7074696F6E73';
wwv_flow_api.g_varchar2_table(29) := '2020202020202020202020202020202020202020202020202020204F626A65637420686F6C64696E6720667572746865722073657474696E67730A202A2040706172616D207B626F6F6C65616E7D2020636F6E6669672E6F7074696F6E732E7375707072';
wwv_flow_api.g_varchar2_table(30) := '6573734368616E67654576656E74202020202020205768656E20747275652074686572652077696C6C206265206E6F206368616E6765206576656E7420726169736564206F6E20616E79206974656D20746861742077696C6C206265206368616E676564';
wwv_flow_api.g_varchar2_table(31) := '0A202A2040706172616D207B626F6F6C65616E7D2020636F6E6669672E6F7074696F6E732E73686F774572726F724173416C657274202020202020202020205768656E207472756520616E79206572726F722077696C6C20626520646973706C61796564';
wwv_flow_api.g_varchar2_table(32) := '20696E20616E20616C6572740A202A2040706172616D207B626F6F6C65616E7D20205B636F6E6669672E6F7074696F6E732E706572666F726D537562737469747574696F6E735D2020202057686574686572207468652073756363657373206F72206572';
wwv_flow_api.g_varchar2_table(33) := '726F72206D6573736167652073686F756C6420706572666F726D206974656D2073757362737469747574696F6E73206265666F7265206265696E672073686F776E0A202A2040706172616D207B626F6F6C65616E7D20205B636F6E6669672E6F7074696F';
wwv_flow_api.g_varchar2_table(34) := '6E732E6573636170654D6573736167655D20202020202020202020205768657468657220746F20657363617065207468652073756363657373206F72206572726F72206D657373616765206265666F7265206265696E672073686F776E0A202A20407061';
wwv_flow_api.g_varchar2_table(35) := '72616D207B66756E6374696F6E7D205B696E6974466E5D2020202020202020202020202020202020202020202020202020202020202020204A61766173637269707420496E697469616C697A6174696F6E20436F64652046756E6374696F6E2C20697420';
wwv_flow_api.g_varchar2_table(36) := '63616E20626520756E646566696E65640A202A2F0A464F532E657865632E706C73716C203D2066756E6374696F6E20286461436F6E746578742C20636F6E6669672C20696E6974466E29207B0A202020202F2F20636F6E7374616E74730A202020207661';
wwv_flow_api.g_varchar2_table(37) := '7220435F44414E474552203D202764616E676572273B0A2020202076617220435F4552524F52203D20276572726F72273B0A2020202076617220435F494E464F203D2027696E666F273B0A2020202076617220435F53554343455353203D202773756363';
wwv_flow_api.g_varchar2_table(38) := '657373273B0A2020202076617220435F5741524E494E47203D20277761726E696E67273B0A0A2020202076617220666F7374724F7074696F6E73203D207B7D3B0A20202020617065782E64656275672E696E666F2827464F53202D204578656375746520';
wwv_flow_api.g_varchar2_table(39) := '504C2F53514C20436F6465272C20636F6E666967293B0A0A20202020666F7374724F7074696F6E73203D207B0A20202020202020206469736D6973733A205B276F6E436C69636B272C20276F6E427574746F6E275D2C0A20202020202020206469736D69';
wwv_flow_api.g_varchar2_table(40) := '737341667465723A20353030302C0A20202020202020206E65776573744F6E546F703A20747275652C0A202020202020202070726576656E744475706C6963617465733A2066616C73652C0A202020202020202065736361706548746D6C3A2066616C73';
wwv_flow_api.g_varchar2_table(41) := '652C0A2020202020202020706F736974696F6E3A2027746F702D7269676874272C0A202020202020202069636F6E436C6173733A206E756C6C2C0A2020202020202020636C656172416C6C3A2066616C73650A202020207D3B0A0A202020202F2F20416C';
wwv_flow_api.g_varchar2_table(42) := '6C6F772074686520646576656C6F70657220746F20706572666F726D20616E79206C617374202863656E7472616C697A656429206368616E676573207573696E67204A61766173637269707420496E697469616C697A6174696F6E20436F646520736574';
wwv_flow_api.g_varchar2_table(43) := '74696E670A202020202F2F20696E206164646974696F6E20746F206F757220706C7567696E20636F6E6669672077652077696C6C207061737320696E206120326E64206F626A65637420666F7220636F6E6669677572696E672074686520464F53206E6F';
wwv_flow_api.g_varchar2_table(44) := '74696669636174696F6E730A2020202069662028696E6974466E20696E7374616E63656F662046756E6374696F6E29207B0A2020202020202020696E6974466E2E63616C6C286461436F6E746578742C20636F6E6669672C20666F7374724F7074696F6E';
wwv_flow_api.g_varchar2_table(45) := '73293B0A202020207D0A0A20202020766172206166456C656D656E7473203D206461436F6E746578742E6166666563746564456C656D656E74733B0A2020202076617220726573756D6543616C6C6261636B203D206461436F6E746578742E726573756D';
wwv_flow_api.g_varchar2_table(46) := '6543616C6C6261636B3B0A2020202076617220616A61784964203D20636F6E6669672E616A617849643B0A2020202076617220706167654974656D73203D20636F6E6669672E706167654974656D733B0A20202020766172207370696E6E657253657474';
wwv_flow_api.g_varchar2_table(47) := '696E6773203D20636F6E6669672E7370696E6E657253657474696E67733B0A2020202076617220636C6F6253657474696E6773203D20636F6E6669672E636C6F6253657474696E67733B0A20202020766172206F7074696F6E73203D20636F6E6669672E';
wwv_flow_api.g_varchar2_table(48) := '6F7074696F6E733B0A20202020766172206D6573736167652C206D657373616765547970652C206D6573736167655469746C653B0A0A202020202F2F20616363657373206E6573746564206F626A6563742070726F706572747920627920737472696E67';
wwv_flow_api.g_varchar2_table(49) := '20706174680A202020202F2F2068747470733A2F2F737461636B6F766572666C6F772E636F6D2F7175657374696F6E732F363439313436332F616363657373696E672D6E65737465642D6A6176617363726970742D6F626A656374732D616E642D617272';

wwv_flow_api.g_varchar2_table(50) := '6179732D62792D737472696E672D706174680A2020202066756E6374696F6E207061727365506174682870617468297B0A202020202020202072657475726E20706174682E73706C697428272E27292E7265647563652866756E6374696F6E286163632C';
wwv_flow_api.g_varchar2_table(51) := '70617468297B0A20202020202020202020202072657475726E206163633F2E5B706174685D0A20202020202020207D2C2077696E646F77290A202020207D0A0A2020202066756E6374696F6E205F68616E646C65526573706F6E73652870446174612920';
wwv_flow_api.g_varchar2_table(52) := '7B0A202020202020202066756E6374696F6E205F706572666F726D416374696F6E7328704461746129207B0A2020202020202020202020202F2F207468697320646566696E657320746865206C697374206F6620616374696F6E7320776520737570706F';
wwv_flow_api.g_varchar2_table(53) := '72740A20202020202020202020202076617220616374696F6E46756E74696F6E73203D207B0A2020202020202020202020202020202068696465526567696F6E733A2066756E6374696F6E2028726567696F6E29207B0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(54) := '20202020202020747279207B0A202020202020202020202020202020202020202020202020617065782E726567696F6E28726567696F6E292E656C656D656E742E6869646528293B0A20202020202020202020202020202020202020207D206361746368';
wwv_flow_api.g_varchar2_table(55) := '20286529207B0A202020202020202020202020202020202020202020202020617065782E64656275672E7761726E28272E2E2E2E204572726F7220686964696E672074686520666F6C6C6F77696E6720726567696F6E3A2027202B20726567696F6E2C20';
wwv_flow_api.g_varchar2_table(56) := '65293B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D2C0A2020202020202020202020202020202073686F77526567696F6E733A2066756E6374696F6E2028726567696F6E29207B0A202020202020';
wwv_flow_api.g_varchar2_table(57) := '2020202020202020202020202020747279207B0A202020202020202020202020202020202020202020202020617065782E726567696F6E28726567696F6E292E656C656D656E742E73686F7728293B0A2020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(58) := '7D20636174636820286529207B0A202020202020202020202020202020202020202020202020617065782E64656275672E7761726E28272E2E2E2E204572726F722073686F77696E672074686520666F6C6C6F77696E6720726567696F6E3A2027202B20';
wwv_flow_api.g_varchar2_table(59) := '726567696F6E2C2065293B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D2C0A20202020202020202020202020202020686964654974656D733A2066756E6374696F6E20286974656D29207B0A2020';
wwv_flow_api.g_varchar2_table(60) := '202020202020202020202020202020202020617065782E6974656D286974656D292E6869646528293B0A202020202020202020202020202020207D2C0A2020202020202020202020202020202073686F774974656D733A2066756E6374696F6E20286974';
wwv_flow_api.g_varchar2_table(61) := '656D29207B0A2020202020202020202020202020202020202020617065782E6974656D286974656D292E73686F7728293B0A202020202020202020202020202020207D2C0A20202020202020202020202020202020656E61626C654974656D733A206675';
wwv_flow_api.g_varchar2_table(62) := '6E6374696F6E20286974656D29207B0A2020202020202020202020202020202020202020617065782E6974656D286974656D292E656E61626C6528293B0A202020202020202020202020202020207D2C0A20202020202020202020202020202020646973';
wwv_flow_api.g_varchar2_table(63) := '61626C654974656D733A2066756E6374696F6E20286974656D29207B0A2020202020202020202020202020202020202020617065782E6974656D286974656D292E64697361626C6528293B0A202020202020202020202020202020207D2C0A2020202020';
wwv_flow_api.g_varchar2_table(64) := '202020202020202020202068696465427574746F6E733A2066756E6374696F6E2028627574746F6E29207B0A2020202020202020202020202020202020202020617065782E6A517565727928272327202B20627574746F6E292E6869646528293B0A2020';
wwv_flow_api.g_varchar2_table(65) := '20202020202020202020202020207D2C0A2020202020202020202020202020202073686F77427574746F6E733A2066756E6374696F6E2028627574746F6E29207B0A2020202020202020202020202020202020202020617065782E6A5175657279282723';
wwv_flow_api.g_varchar2_table(66) := '27202B20627574746F6E292E73686F7728293B0A202020202020202020202020202020207D2C0A20202020202020202020202020202020656E61626C65427574746F6E733A2066756E6374696F6E2028627574746F6E29207B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(67) := '20202020202020202020617065782E6A517565727928272327202B20627574746F6E292E61747472282264697361626C6564222C2066616C7365293B0A202020202020202020202020202020207D2C0A2020202020202020202020202020202064697361';
wwv_flow_api.g_varchar2_table(68) := '626C65427574746F6E733A2066756E6374696F6E2028627574746F6E29207B0A2020202020202020202020202020202020202020617065782E6A517565727928272327202B20627574746F6E292E61747472282264697361626C6564222C207472756529';
wwv_flow_api.g_varchar2_table(69) := '3B0A202020202020202020202020202020207D2C0A2020202020202020202020202020202073657456616C7565733A2066756E6374696F6E20286974656D29207B0A20202020202020202020202020202020202020202473286974656D2E6E616D652C20';
wwv_flow_api.g_varchar2_table(70) := '6974656D2E76616C75652C206974656D2E646973706C61792C206974656D2E73757070726573734368616E67654576656E74293B0A202020202020202020202020202020207D2C0A20202020202020202020202020202020636C6561724572726F72733A';
wwv_flow_api.g_varchar2_table(71) := '2066756E6374696F6E202829207B0A2020202020202020202020202020202020202020617065782E6D6573736167652E636C6561724572726F727328293B0A202020202020202020202020202020207D2C0A202020202020202020202020202020206974';
wwv_flow_api.g_varchar2_table(72) := '656D4572726F72733A2066756E6374696F6E20286974656D29207B0A2020202020202020202020202020202020202020766172206D657373616765203D20617065782E7574696C2E6170706C7954656D706C617465286974656D2E6D6573736167652C20';
wwv_flow_api.g_varchar2_table(73) := '7B0A20202020202020202020202020202020202020202020202064656661756C7445736361706546696C7465723A206E756C6C0A20202020202020202020202020202020202020207D293B0A202020202020202020202020202020202020202061706578';
wwv_flow_api.g_varchar2_table(74) := '2E6D6573736167652E73686F774572726F7273287B0A202020202020202020202020202020202020202020202020747970653A20435F4552524F522C0A2020202020202020202020202020202020202020202020206C6F636174696F6E3A206974656D2E';
wwv_flow_api.g_varchar2_table(75) := '6C6F636174696F6E207C7C205B27696E6C696E65272C202770616765275D2C0A202020202020202020202020202020202020202020202020706167654974656D3A206974656D2E6E616D652C0A2020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(76) := '206D6573736167653A206D6573736167652C0A2020202020202020202020202020202020202020202020202F2F616E79206573636170696E6720697320617373756D656420746F2068617665206265656E20646F6E65206279206E6F770A202020202020';
wwv_flow_api.g_varchar2_table(77) := '202020202020202020202020202020202020756E736166653A2066616C73650A20202020202020202020202020202020202020207D293B0A202020202020202020202020202020207D2C0A20202020202020202020202020202020726566726573685265';
wwv_flow_api.g_varchar2_table(78) := '67696F6E733A2066756E6374696F6E2028726567696F6E29207B0A2020202020202020202020202020202020202020747279207B0A202020202020202020202020202020202020202020202020617065782E726567696F6E28726567696F6E292E726566';
wwv_flow_api.g_varchar2_table(79) := '7265736828293B0A20202020202020202020202020202020202020207D20636174636820286529207B0A202020202020202020202020202020202020202020202020617065782E64656275672E7761726E28272E2E2E2E204572726F7220726566726573';
wwv_flow_api.g_varchar2_table(80) := '68696E672074686520666F6C6C6F77696E6720726567696F6E3A2027202B20726567696F6E2C2065293B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D2C0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(81) := '726566726573684974656D733A2066756E6374696F6E20286974656D29207B0A2020202020202020202020202020202020202020747279207B0A202020202020202020202020202020202020202020202020617065782E6974656D286974656D292E7265';
wwv_flow_api.g_varchar2_table(82) := '667265736828293B0A20202020202020202020202020202020202020207D20636174636820286529207B0A202020202020202020202020202020202020202020202020617065782E64656275672E7761726E28272E2E2E2E204572726F72207265667265';
wwv_flow_api.g_varchar2_table(83) := '7368696E672074686520666F6C6C6F77696E67206974656D3A2027202B206974656D2C2065293B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D2C0A20202020202020202020202020202020666972';
wwv_flow_api.g_varchar2_table(84) := '654576656E74733A2066756E6374696F6E20286529207B0A2020202020202020202020202020202020202020617065782E6576656E742E7472696767657228652E73656C6563746F72207C7C2027626F6479272C20652E6E616D652C20652E6461746129';
wwv_flow_api.g_varchar2_table(85) := '3B0A202020202020202020202020202020207D2C0A2020202020202020202020202020202072656D6F7665436C6173733A2066756E6374696F6E20286974656D29207B0A2020202020202020202020202020202020202020617065782E6A517565727928';
wwv_flow_api.g_varchar2_table(86) := '6974656D2E73656C6563746F72292E72656D6F7665436C617373286974656D2E636C617373293B0A202020202020202020202020202020207D2C0A20202020202020202020202020202020616464436C6173733A2066756E6374696F6E20286974656D29';
wwv_flow_api.g_varchar2_table(87) := '207B0A2020202020202020202020202020202020202020617065782E6A5175657279286974656D2E73656C6563746F72292E616464436C617373286974656D2E636C617373293B0A202020202020202020202020202020207D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(88) := '20207D3B0A2020202020202020202020202F2F2069746572617465207468726F756768206F757220737570706F7274656420616374696F6E2066756E6374696F6E7320616E64207468656E207468726F756768206F75722064617461206F626A65637420';
wwv_flow_api.g_varchar2_table(89) := '746F20736565207768696368206F6E65732073686F756C642062652065786563757465640A2020202020202020202020204F626A6563742E656E747269657328616374696F6E46756E74696F6E73292E666F72456163682866756E6374696F6E20286163';
wwv_flow_api.g_varchar2_table(90) := '74696F6E29207B0A20202020202020202020202020202020766172206D6574686F64203D20616374696F6E5B305D2C0A2020202020202020202020202020202020202020666E203D20616374696F6E5B315D3B0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(91) := '696620286D6574686F6420696E2070446174612026262041727261792E697341727261792870446174615B6D6574686F645D2929207B0A202020202020202020202020202020202020202070446174615B6D6574686F645D2E666F724561636828666E29';
wwv_flow_api.g_varchar2_table(92) := '3B0A202020202020202020202020202020207D20656C736520696620286D6574686F6420696E207044617461202626205B27626F6F6C65616E272C20276E756D626572272C2027737472696E67275D2E696E636C7564657328747970656F662070446174';
wwv_flow_api.g_varchar2_table(93) := '615B6D6574686F645D2929207B0A2020202020202020202020202020202020202020666E2E63616C6C2870446174612C2070446174615B6D6574686F645D293B0A202020202020202020202020202020207D0A2020202020202020202020207D293B0A0A';
wwv_flow_api.g_varchar2_table(94) := '2020202020202020202020202F2F204F7074696F6E616C6C79207365742074686520666F637573206F6E20612070616765206974656D0A2020202020202020202020206966202870446174612E736574466F6375734974656D29207B0A20202020202020';
wwv_flow_api.g_varchar2_table(95) := '202020202020202020747279207B0A2020202020202020202020202020202020202020617065782E6974656D2870446174612E736574466F6375734974656D292E736574466F63757328293B0A202020202020202020202020202020207D206361746368';
wwv_flow_api.g_varchar2_table(96) := '20286529207B0A2020202020202020202020202020202020202020617065782E64656275672E7761726E28272E2E2E2E204572726F722073657474696E6720666F6375732074686520666F6C6C6F77696E67206974656D3A2027202B2070446174612E73';
wwv_flow_api.g_varchar2_table(97) := '6574466F6375734974656D2C2065293B0A202020202020202020202020202020207D0A2020202020202020202020207D0A0A20202020202020207D202F2F20656F66205F706572666F726D416374696F6E730A0A20202020202020202F2F204D61696E20';
wwv_flow_api.g_varchar2_table(98) := '68616E646C696E670A20202020202020206966202870446174612E737461747573203D3D20435F5355434345535329207B0A202020202020202020202020766172206974656D436F756E742C206974656D41727261792C2063616E63656C416374696F6E';
wwv_flow_api.g_varchar2_table(99) := '73203D2066616C73653B0A0A2020202020202020202020202F2F20636865636B2069662074686520646576656C6F7065722077616E747320746F2063616E63656C20666F6C6C6F77696E6720616374696F6E730A20202020202020202020202063616E63';
wwv_flow_api.g_varchar2_table(100) := '656C416374696F6E73203D20212170446174612E63616E63656C416374696F6E733B202F2F20656E737572652077652068617665206120626F6F6C65616E20726573706F6E73652069662061747472696275746520697320756E646566696E65640A0A20';
wwv_flow_api.g_varchar2_table(101) := '20202020202020202020202F2F726567756C61722070616765206974656D730A2020202020202020202020206966202870446174612026262070446174612E6974656D7329207B0A202020202020202020202020202020206974656D4172726179203D20';
wwv_flow_api.g_varchar2_table(102) := '70446174612E6974656D733B0A202020202020202020202020202020206974656D436F756E74203D206974656D41727261792E6C656E6774683B0A20202020202020202020202020202020666F7220287661722069203D20303B2069203C206974656D43';
wwv_flow_api.g_varchar2_table(103) := '6F756E743B20692B2B29207B0A2020202020202020202020202020202020202020696620286974656D41727261795B695D2E646973706C617929207B0A2020202020202020202020202020202020202020202020202473286974656D41727261795B695D';
wwv_flow_api.g_varchar2_table(104) := '2E69642C206974656D41727261795B695D2E76616C75652C206974656D41727261795B695D2E646973706C61792C206F7074696F6E732E73757070726573734368616E67654576656E74293B0A20202020202020202020202020202020202020207D2065';
wwv_flow_api.g_varchar2_table(105) := '6C7365207B0A2020202020202020202020202020202020202020202020202473286974656D41727261795B695D2E69642C206974656D41727261795B695D2E76616C75652C206E756C6C2C206F7074696F6E732E73757070726573734368616E67654576';
wwv_flow_api.g_varchar2_table(106) := '656E74293B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D0A2020202020202020202020207D0A0A0A2020202020202020202020202F2F636C6F622070616765206974656D2F207661726961626C65';
wwv_flow_api.g_varchar2_table(107) := '2F207661726961626C65206173206A736F6E2F207061737320696E746F20612066756E6374696F6E206173206A736F6E0A20202020202020202020202069662028636C6F6253657474696E67732E72657475726E436C6F6229207B0A2020202020202020';
wwv_flow_api.g_varchar2_table(108) := '20202020202020207377697463682028636C6F6253657474696E67732E72657475726E436C6F62496E746F29207B0A2020202020202020202020202020202020202020636173652027706167656974656D273A0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(109) := '2020202020202020247328636C6F6253657474696E67732E72657475726E436C6F624974656D2C2070446174612E636C6F622C206E756C6C2C206F7074696F6E732E73757070726573734368616E67654576656E74293B0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(110) := '202020202020202020202020627265616B3B0A20202020202020202020202020202020202020206361736520276A6176617363726970747661726961626C65273A0A202020202020202020202020202020202020202020202020464F532E657865632E63';
wwv_flow_api.g_varchar2_table(111) := '72656174654E65737465644F626A656374416E6441737369676E2877696E646F772C20636C6F6253657474696E67732E72657475726E436C6F625661726961626C652C2070446174612E636C6F62293B0A20202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(112) := '2020202020627265616B3B0A20202020202020202020202020202020202020206361736520276A6176617363726970747661726961626C656A736F6E273A0A20202020202020202020202020202020202020202020202070446174612E65786563506C73';
wwv_flow_api.g_varchar2_table(113) := '716C526573756C74203D204A534F4E2E70617273652870446174612E636C6F62293B0A202020202020202020202020202020202020202020202020464F532E657865632E6372656174654E65737465644F626A656374416E6441737369676E2877696E64';
wwv_flow_api.g_varchar2_table(114) := '6F772C20636C6F6253657474696E67732E72657475726E436C6F625661726961626C652C2070446174612E65786563506C73716C526573756C74293B0A2020202020202020202020202020202020202020202020205F706572666F726D416374696F6E73';
wwv_flow_api.g_varchar2_table(115) := '2870446174612E65786563506C73716C526573756C74293B0A202020202020202020202020202020202020202020202020627265616B3B0A20202020202020202020202020202020202020206361736520276A617661736372697074696E697461736A73';
wwv_flow_api.g_varchar2_table(116) := '6F6E273A0A20202020202020202020202020202020202020202020202069662028747970656F6620636F6E6669672E636C6F6243616C6C6261636B203D3D3D202766756E6374696F6E2729207B0A20202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(117) := '20202020202070446174612E65786563506C73716C526573756C74203D204A534F4E2E70617273652870446174612E636C6F62293B0A20202020202020202020202020202020202020202020202020202020636F6E6669672E636C6F6243616C6C626163';
wwv_flow_api.g_varchar2_table(118) := '6B2E63616C6C28636F6E6669672C2070446174612E65786563506C73716C526573756C74293B0A2020202020202020202020202020202020202020202020207D20656C7365207B0A20202020202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(119) := '617065782E64656275672E7761726E28272E2E2E2E204572726F722022636C6F6243616C6C6261636B222066756E6374696F6E206973206D697373696E672066726F6D2074686520636F6E666967206F7074696F6E732E20596F75206D75737420646566';
wwv_flow_api.g_varchar2_table(120) := '696E6520746869732066756E6374696F6E20696E2074686520224A61766173637269707420496E697469616C697A6174696F6E20436F6465222061747472696275746520696E20796F75722064796E616D696320616374696F6E2127293B0A2020202020';
wwv_flow_api.g_varchar2_table(121) := '202020202020202020202020202020202020207D0A202020202020202020202020202020202020202020202020627265616B3B0A202020202020202020202020202020207D0A2020202020202020202020207D0A0A2020202020202020202020202F2F20';
wwv_flow_api.g_varchar2_table(122) := '4E6F74696669636174696F6E206F76657272696465732066726F6D20646576656C6F7065720A2020202020202020202020206966202870446174612E65786563506C73716C526573756C7429207B0A202020202020202020202020202020206966202870';
wwv_flow_api.g_varchar2_table(123) := '446174612E65786563506C73716C526573756C742E63616E63656C416374696F6E7329207B0A202020202020202020202020202020202020202063616E63656C416374696F6E73203D20747275653B0A202020202020202020202020202020207D0A2020';
wwv_flow_api.g_varchar2_table(124) := '20202020202020202020202020206966202870446174612E65786563506C73716C526573756C742E6E6F74696669636174696F6E29207B0A2020202020202020202020202020202020202020766172206E6F74696669636174696F6E203D207044617461';
wwv_flow_api.g_varchar2_table(125) := '2E65786563506C73716C526573756C742E6E6F74696669636174696F6E3B0A202020202020202020202020202020202020202070446174612E6D657373616765203D206E6F74696669636174696F6E2E6D6573736167653B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(126) := '20202020202020202070446174612E6D65737361676554797065203D206E6F74696669636174696F6E2E747970653B0A202020202020202020202020202020202020202070446174612E6D6573736167655469746C65203D206E6F74696669636174696F';
wwv_flow_api.g_varchar2_table(127) := '6E2E7469746C653B0A202020202020202020202020202020207D0A2020202020202020202020207D0A0A2020202020202020202020202F2F204E6F74696669636174696F6E0A2020202020202020202020206966202870446174612E6D65737361676529';
wwv_flow_api.g_varchar2_table(128) := '207B0A202020202020202020202020202020206D65737361676554797065203D202870446174612E6D65737361676554797065202626205B435F494E464F2C20435F5741524E494E472C20435F535543434553532C20435F4552524F522C20435F44414E';
wwv_flow_api.g_varchar2_table(129) := '4745525D2E696E636C756465732870446174612E6D657373616765547970652929203F2070446174612E6D65737361676554797065203A20435F535543434553533B0A202020202020202020202020202020206D65737361676554797065203D20286D65';
wwv_flow_api.g_varchar2_table(130) := '737361676554797065203D3D3D20435F44414E47455229203F20435F4552524F52203A206D657373616765547970653B0A0A202020202020202020202020202020206D6573736167655469746C65203D2070446174612E6D6573736167655469746C653B';
wwv_flow_api.g_varchar2_table(131) := '0A202020202020202020202020202020206D657373616765203D2070446174612E6D6573736167653B0A0A202020202020202020202020202020202F2F20706572666F726D696E6720636C69656E742D73696465206974656D2073757362737469747574';
wwv_flow_api.g_varchar2_table(132) := '696F6E730A20202020202020202020202020202020696620286D6573736167655469746C65202626206F7074696F6E732E706572666F726D537562737469747574696F6E7329207B0A20202020202020202020202020202020202020206D657373616765';
wwv_flow_api.g_varchar2_table(133) := '5469746C65203D20617065782E7574696C2E6170706C7954656D706C617465286D6573736167655469746C652C207B2064656661756C7445736361706546696C7465723A206E756C6C207D293B0A202020202020202020202020202020207D0A20202020';
wwv_flow_api.g_varchar2_table(134) := '202020202020202020202020696620286D657373616765202626206F7074696F6E732E706572666F726D537562737469747574696F6E7329207B0A20202020202020202020202020202020202020206D657373616765203D20617065782E7574696C2E61';
wwv_flow_api.g_varchar2_table(135) := '70706C7954656D706C617465286D6573736167652C207B2064656661756C7445736361706546696C7465723A206E756C6C207D293B0A202020202020202020202020202020207D0A0A202020202020202020202020202020202F2F20706572666F726D69';
wwv_flow_api.g_varchar2_table(136) := '6E67206573636170696E670A20202020202020202020202020202020696620286D6573736167655469746C65202626206F7074696F6E732E6573636170654D65737361676529207B0A20202020202020202020202020202020202020206D657373616765';
wwv_flow_api.g_varchar2_table(137) := '5469746C65203D20617065782E7574696C2E65736361706548544D4C286D6573736167655469746C65293B0A202020202020202020202020202020207D0A20202020202020202020202020202020696620286D657373616765202626206F7074696F6E73';
wwv_flow_api.g_varchar2_table(138) := '2E6573636170654D65737361676529207B0A20202020202020202020202020202020202020206D657373616765203D20617065782E7574696C2E65736361706548544D4C286D657373616765293B0A202020202020202020202020202020207D0A0A2020';
wwv_flow_api.g_varchar2_table(139) := '20202020202020202020202020202F2F206E6F746966790A20202020202020202020202020202020242E657874656E6428666F7374724F7074696F6E732C207B0A20202020202020202020202020202020202020206D6573736167653A20286D65737361';
wwv_flow_api.g_varchar2_table(140) := '67655469746C6529203F206D657373616765203A20756E646566696E65642C0A20202020202020202020202020202020202020207469746C653A2028216D6573736167655469746C6529203F206D657373616765203A206D6573736167655469746C652C';
wwv_flow_api.g_varchar2_table(141) := '0A2020202020202020202020202020202020202020747970653A206D657373616765547970652C0A20202020202020202020202020202020202020206469736D69737341667465723A20286D65737361676554797065203D3D3D20435F4552524F522920';
wwv_flow_api.g_varchar2_table(142) := '3F20756E646566696E6564203A20666F7374724F7074696F6E732E6469736D69737341667465720A202020202020202020202020202020207D293B0A20202020202020202020202020202020666F7374725B6D657373616765547970655D28666F737472';
wwv_flow_api.g_varchar2_table(143) := '4F7074696F6E73293B0A2020202020202020202020207D0A2020202020202020202020202F2F204F7074696F6E616C6C79206669726520616E206576656E742069662074686520646576656C6F70657220646569666E6564206F6E65207573696E672061';
wwv_flow_api.g_varchar2_table(144) := '7065785F6170706C69636174696F6E2E675F7830350A2020202020202020202020206966202870446174612E6576656E744E616D6529207B0A20202020202020202020202020202020617065782E6576656E742E747269676765722827626F6479272C20';
wwv_flow_api.g_varchar2_table(145) := '70446174612E6576656E744E616D652C207044617461293B0A2020202020202020202020207D0A0A2020202020202020202020202F2A20526573756D6520657865637574696F6E206F6620616374696F6E73206865726520616E6420706173732066616C';
wwv_flow_api.g_varchar2_table(146) := '736520746F207468652063616C6C6261636B2C20746F20696E646963617465206E6F0A2020202020202020202020206572726F7220686173206F6363757272656420776974682074686520416A61782063616C6C2E202A2F0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(147) := '20617065782E64612E726573756D6528726573756D6543616C6C6261636B2C2063616E63656C416374696F6E73293B0A20202020202020207D20656C7365206966202870446174612E737461747573203D3D20435F4552524F5229207B0A202020202020';
wwv_flow_api.g_varchar2_table(148) := '2020202020206966202870446174612E6D65737361676529207B0A202020202020202020202020202020202F2F20706572666F726D20616E7920737562737469747574696F6E730A202020202020202020202020202020206D6573736167655469746C65';
wwv_flow_api.g_varchar2_table(149) := '203D2070446174612E6D6573736167655469746C653B0A202020202020202020202020202020206D657373616765203D2070446174612E6D6573736167653B0A0A20202020202020202020202020202020696620286D6573736167655469746C65202626';
wwv_flow_api.g_varchar2_table(150) := '206F7074696F6E732E706572666F726D537562737469747574696F6E7329207B0A20202020202020202020202020202020202020206D6573736167655469746C65203D20617065782E7574696C2E6170706C7954656D706C617465286D65737361676554';
wwv_flow_api.g_varchar2_table(151) := '69746C652C207B2064656661756C7445736361706546696C7465723A206E756C6C207D293B0A202020202020202020202020202020207D0A20202020202020202020202020202020696620286D657373616765202626206F7074696F6E732E706572666F';
wwv_flow_api.g_varchar2_table(152) := '726D537562737469747574696F6E7329207B0A20202020202020202020202020202020202020206D657373616765203D20617065782E7574696C2E6170706C7954656D706C617465286D6573736167652C207B2064656661756C7445736361706546696C';
wwv_flow_api.g_varchar2_table(153) := '7465723A206E756C6C207D293B0A202020202020202020202020202020207D0A0A202020202020202020202020202020202F2F20706572666F726D696E67206573636170696E670A20202020202020202020202020202020696620286D65737361676554';
wwv_flow_api.g_varchar2_table(154) := '69746C65202626206F7074696F6E732E6573636170654D65737361676529207B0A20202020202020202020202020202020202020206D6573736167655469746C65203D20617065782E7574696C2E65736361706548544D4C286D6573736167655469746C';
wwv_flow_api.g_varchar2_table(155) := '65293B0A202020202020202020202020202020207D0A20202020202020202020202020202020696620286D657373616765202626206F7074696F6E732E6573636170654D65737361676529207B0A20202020202020202020202020202020202020206D65';
wwv_flow_api.g_varchar2_table(156) := '7373616765203D20617065782E7574696C2E65736361706548544D4C286D657373616765293B0A202020202020202020202020202020207D0A0A20202020202020202020202020202020696620286F7074696F6E732E73686F774572726F724173416C65';
wwv_flow_api.g_varchar2_table(157) := '727429207B0A2020202020202020202020202020202020202020617065782E6D6573736167652E616C657274286D657373616765293B0A202020202020202020202020202020207D20656C7365207B0A2020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(158) := '242E657874656E6428666F7374724F7074696F6E732C207B0A2020202020202020202020202020202020202020202020206D6573736167653A20286D6573736167655469746C6529203F206D657373616765203A20756E646566696E65642C0A20202020';
wwv_flow_api.g_varchar2_table(159) := '20202020202020202020202020202020202020207469746C653A2028216D6573736167655469746C6529203F206D657373616765203A206D6573736167655469746C652C0A202020202020202020202020202020202020202020202020747970653A2043';
wwv_flow_api.g_varchar2_table(160) := '5F4552524F522C0A2020202020202020202020202020202020202020202020206469736D69737341667465723A20756E646566696E65640A20202020202020202020202020202020202020207D293B0A2020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(161) := '666F7374722E6572726F7228666F7374724F7074696F6E73293B0A0A20202020202020202020202020202020202020202F2F204F7074696F6E616C6C79206669726520616E206576656E742069662074686520646576656C6F70657220646566696E6564';
wwv_flow_api.g_varchar2_table(162) := '206F6E65207573696E6720617065785F6170706C69636174696F6E2E675F7830350A20202020202020202020202020202020202020206966202870446174612E6576656E744E616D6529207B0A2020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(163) := '20617065782E6576656E742E747269676765722827626F6479272C2070446174612E6576656E744E616D652C207044617461293B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D0A20202020202020';
wwv_flow_api.g_varchar2_table(164) := '20202020207D0A2020202020202020202020202F2F2063616E63656C20616374696F6E7320617320746865726520697320616E20657863657074696F6E0A202020202020202020202020617065782E64612E726573756D6528726573756D6543616C6C62';
wwv_flow_api.g_varchar2_table(165) := '61636B2C2074727565293B0A20202020202020207D0A202020207D0A0A2020202076617220636C6F62546F5375626D69743B0A0A2020202069662028636C6F6253657474696E67732E7375626D6974436C6F6229207B0A20202020202020207377697463';
wwv_flow_api.g_varchar2_table(166) := '682028636C6F6253657474696E67732E7375626D6974436C6F6246726F6D29207B0A202020202020202020202020636173652027706167656974656D273A0A20202020202020202020202020202020636C6F62546F5375626D6974203D20617065782E69';
wwv_flow_api.g_varchar2_table(167) := '74656D28636C6F6253657474696E67732E7375626D6974436C6F624974656D292E67657456616C756528293B0A20202020202020202020202020202020627265616B3B0A2020202020202020202020206361736520276A61766173637269707476617269';
wwv_flow_api.g_varchar2_table(168) := '61626C65273A0A2020202020202020202020202020202076617220746F5375626D6974203D2070617273655061746828636C6F6253657474696E67732E7375626D6974436C6F625661726961626C65293B2F2F77696E646F775B636C6F6253657474696E';
wwv_flow_api.g_varchar2_table(169) := '67732E7375626D6974436C6F625661726961626C655D3B0A0A2020202020202020202020202020202069662028746F5375626D697420696E7374616E63656F66204F626A65637429207B0A2020202020202020202020202020202020202020636C6F6254';
wwv_flow_api.g_varchar2_table(170) := '6F5375626D6974203D204A534F4E2E737472696E6769667928746F5375626D6974293B0A202020202020202020202020202020207D20656C7365207B0A2020202020202020202020202020202020202020636C6F62546F5375626D6974203D20746F5375';
wwv_flow_api.g_varchar2_table(171) := '626D69743B0A202020202020202020202020202020207D0A20202020202020202020202020202020627265616B3B0A2020202020202020202020206361736520276A617661736372697074696E6974273A0A202020202020202020202020202020206966';
wwv_flow_api.g_varchar2_table(172) := '2028747970656F6620636F6E6669672E7375626D6974436C6F62203D3D3D202766756E6374696F6E2729207B0A2020202020202020202020202020202020202020636C6F62546F5375626D6974203D20636F6E6669672E7375626D6974436C6F622E6361';
wwv_flow_api.g_varchar2_table(173) := '6C6C28636F6E666967293B0A202020202020202020202020202020207D20656C7365207B0A2020202020202020202020202020202020202020617065782E64656275672E7761726E28272E2E2E2E204572726F7220227375626D6974436C6F6222206675';

wwv_flow_api.g_varchar2_table(174) := '6E6374696F6E206973206D697373696E672066726F6D2074686520636F6E666967206F7074696F6E732E20596F75206D75737420646566696E6520746869732066756E6374696F6E20696E2074686520224A61766173637269707420496E697469616C69';
wwv_flow_api.g_varchar2_table(175) := '7A6174696F6E20436F6465222061747472696275746520696E20796F75722064796E616D696320616374696F6E2127293B0A202020202020202020202020202020207D0A20202020202020202020202020202020627265616B3B0A202020202020202020';
wwv_flow_api.g_varchar2_table(176) := '20202064656661756C743A0A20202020202020202020202020202020627265616B3B0A20202020202020207D0A202020207D0A0A20202020766172206C6F6164696E67496E64696361746F72466E3B0A0A202020202F2F636F6E66696775726573207468';
wwv_flow_api.g_varchar2_table(177) := '652073686F77696E6720616E6420686964696E67206F66206120706F737369626C65207370696E6E65720A20202020696620287370696E6E657253657474696E67732E73686F775370696E6E657229207B0A20202020202020202F2F20776F726B206F75';
wwv_flow_api.g_varchar2_table(178) := '7420776865726520746F2073686F7720746865207370696E6E65720A20202020202020207370696E6E657253657474696E67732E7370696E6E6572456C656D656E74203D20287370696E6E657253657474696E67732E73686F775370696E6E65724F6E52';
wwv_flow_api.g_varchar2_table(179) := '6567696F6E29203F206166456C656D656E7473203A2027626F6479273B0A20202020202020206C6F6164696E67496E64696361746F72466E203D202866756E6374696F6E2028656C656D656E742C2073686F774F7665726C617929207B0A202020202020';
wwv_flow_api.g_varchar2_table(180) := '2020202020207661722066697865644F6E426F6479203D20656C656D656E74203D3D2027626F6479273B0A20202020202020202020202072657475726E2066756E6374696F6E2028704C6F6164696E67496E64696361746F7229207B0A20202020202020';
wwv_flow_api.g_varchar2_table(181) := '202020202020202020766172206F7665726C6179243B0A20202020202020202020202020202020766172207370696E6E657224203D20617065782E7574696C2E73686F775370696E6E657228656C656D656E742C207B2066697865643A2066697865644F';
wwv_flow_api.g_varchar2_table(182) := '6E426F6479207D293B0A202020202020202020202020202020206966202873686F774F7665726C617929207B0A20202020202020202020202020202020202020206F7665726C617924203D202428273C64697620636C6173733D22666F732D726567696F';
wwv_flow_api.g_varchar2_table(183) := '6E2D6F7665726C617927202B202866697865644F6E426F6479203F20272D666978656427203A20272729202B2027223E3C2F6469763E27292E70726570656E64546F28656C656D656E74293B0A202020202020202020202020202020207D0A2020202020';
wwv_flow_api.g_varchar2_table(184) := '202020202020202020202066756E6374696F6E2072656D6F76655370696E6E65722829207B0A2020202020202020202020202020202020202020696620286F7665726C61792429207B0A2020202020202020202020202020202020202020202020206F76';
wwv_flow_api.g_varchar2_table(185) := '65726C6179242E72656D6F766528293B0A20202020202020202020202020202020202020207D0A20202020202020202020202020202020202020207370696E6E6572242E72656D6F766528293B0A202020202020202020202020202020207D0A20202020';
wwv_flow_api.g_varchar2_table(186) := '2020202020202020202020202F2F746869732066756E6374696F6E206D7573742072657475726E20612066756E6374696F6E2077686963682068616E646C6573207468652072656D6F76696E67206F6620746865207370696E6E65720A20202020202020';
wwv_flow_api.g_varchar2_table(187) := '20202020202020202072657475726E2072656D6F76655370696E6E65723B0A2020202020202020202020207D3B0A20202020202020207D29287370696E6E657253657474696E67732E7370696E6E6572456C656D656E742C207370696E6E657253657474';
wwv_flow_api.g_varchar2_table(188) := '696E67732E73686F775370696E6E65724F7665726C6179293B0A202020207D0A0A202020202F2F20436865636B20746F20736565206966206F757220636C6F622069732061637475616C6C7920612070726F6D69736520287468697320636F646520776F';
wwv_flow_api.g_varchar2_table(189) := '726B732077686574686572206974277320612076616C7565206F7220612070726F6D697365290A202020202F2F2068747470733A2F2F737461636B6F766572666C6F772E636F6D2F7175657374696F6E732F32373734363330342F686F772D646F2D692D';
wwv_flow_api.g_varchar2_table(190) := '74656C6C2D69662D616E2D6F626A6563742D69732D612D70726F6D6973650A2020202050726F6D6973652E7265736F6C766528636C6F62546F5375626D6974292E7468656E2866756E6374696F6E202876616C756529207B0A20202020202020202F2F20';
wwv_flow_api.g_varchar2_table(191) := '72756E2074686520706C2F73716C20636F646520696E207468652064617461626173650A202020202020202076617220726573756C74203D20617065782E7365727665722E706C7567696E28616A617849642C207B0A2020202020202020202020207061';
wwv_flow_api.g_varchar2_table(192) := '67654974656D733A20706167654974656D732E6974656D73546F5375626D69742C0A202020202020202020202020705F636C6F625F30313A2076616C75650A20202020202020207D2C207B0A20202020202020202020202064617461547970653A20276A';
wwv_flow_api.g_varchar2_table(193) := '736F6E272C0A2020202020202020202020206C6F6164696E67496E64696361746F723A206C6F6164696E67496E64696361746F72466E2C0A2020202020202020202020207461726765743A206461436F6E746578742E62726F777365724576656E742E74';
wwv_flow_api.g_varchar2_table(194) := '61726765740A20202020202020207D293B0A0A20202020202020202F2F2068616E646C6520616A617820726573756C74207573696E67206F757220726573756C742070726F6D6973650A2020202020202020726573756C742E646F6E652866756E637469';
wwv_flow_api.g_varchar2_table(195) := '6F6E20286461746129207B0A2020202020202020202020205F68616E646C65526573706F6E73652864617461293B0A20202020202020207D292E6661696C2866756E6374696F6E20286A715848522C20746578745374617475732C206572726F72546872';
wwv_flow_api.g_varchar2_table(196) := '6F776E29207B0A202020202020202020202020617065782E64612E68616E646C65416A61784572726F7273286A715848522C20746578745374617475732C206572726F725468726F776E2C20726573756D6543616C6C6261636B293B0A20202020202020';
wwv_flow_api.g_varchar2_table(197) := '207D293B0A202020207D292E63617463682866756E6374696F6E202865727229207B0A2020202020202020617065782E6465627567282723234552524F52232320464F532E457865637574652E504C53514C272C20657272293B0A202020202020202061';
wwv_flow_api.g_varchar2_table(198) := '7065782E64612E68616E646C65416A61784572726F7273287B207374617475733A20393939207D2C2027464F532E457865637574652E504C53514C272C206572722C20726573756D6543616C6C6261636B293B0A202020207D293B0A7D3B0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(2735854986111362)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_file_name=>'js/script.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2E666F732D726567696F6E2D6F7665726C61797B0A20202020706F736974696F6E3A206162736F6C7574653B0A202020207A2D696E6465783A203435303B0A202020207669736962696C6974793A2076697369626C653B0A2020202077696474683A2031';
wwv_flow_api.g_varchar2_table(2) := '3030253B0A202020206865696768743A20313030253B0A202020206261636B67726F756E643A2072676261283235352C203235352C203235352C20302E35293B0A7D0A0A2E666F732D726567696F6E2D6F7665726C61792D66697865647B0A2020202070';
wwv_flow_api.g_varchar2_table(3) := '6F736974696F6E3A2066697865643B0A202020207A2D696E6465783A203435303B0A202020207669736962696C6974793A2076697369626C653B0A2020202077696474683A20313030253B0A202020206865696768743A20313030253B0A202020206261';
wwv_flow_api.g_varchar2_table(4) := '636B67726F756E643A2072676261283235352C203235352C203235352C20302E35293B0A7D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(8442553266233027)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_file_name=>'css/style.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2E666F732D726567696F6E2D6F7665726C61792C2E666F732D726567696F6E2D6F7665726C61792D66697865647B706F736974696F6E3A6162736F6C7574653B7A2D696E6465783A3435303B7669736962696C6974793A76697369626C653B7769647468';
wwv_flow_api.g_varchar2_table(2) := '3A313030253B6865696768743A313030253B6261636B67726F756E643A72676261283235352C3235352C3235352C2E35297D2E666F732D726567696F6E2D6F7665726C61792D66697865647B706F736974696F6E3A66697865647D0A2F2A2320736F7572';
wwv_flow_api.g_varchar2_table(3) := '63654D617070696E6755524C3D7374796C652E6373732E6D61702A2F';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(8443966375248255)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_file_name=>'css/style.min.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C22736F7572636573223A5B227374796C652E637373225D2C226E616D6573223A5B5D2C226D617070696E6773223A22414141412C6D422C434153412C79422C434152492C69422C434143412C572C434143412C6B422C43';
wwv_flow_api.g_varchar2_table(2) := '4143412C552C434143412C572C434143412C2B422C4341474A2C79422C434143492C63222C2266696C65223A227374796C652E637373222C22736F7572636573436F6E74656E74223A5B222E666F732D726567696F6E2D6F7665726C61797B5C6E202020';
wwv_flow_api.g_varchar2_table(3) := '20706F736974696F6E3A206162736F6C7574653B5C6E202020207A2D696E6465783A203435303B5C6E202020207669736962696C6974793A2076697369626C653B5C6E2020202077696474683A20313030253B5C6E202020206865696768743A20313030';
wwv_flow_api.g_varchar2_table(4) := '253B5C6E202020206261636B67726F756E643A2072676261283235352C203235352C203235352C20302E35293B5C6E7D5C6E5C6E2E666F732D726567696F6E2D6F7665726C61792D66697865647B5C6E20202020706F736974696F6E3A2066697865643B';
wwv_flow_api.g_varchar2_table(5) := '5C6E202020207A2D696E6465783A203435303B5C6E202020207669736962696C6974793A2076697369626C653B5C6E2020202077696474683A20313030253B5C6E202020206865696768743A20313030253B5C6E202020206261636B67726F756E643A20';
wwv_flow_api.g_varchar2_table(6) := '72676261283235352C203235352C203235352C20302E35293B5C6E7D225D7D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(8444336713248255)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_file_name=>'css/style.css.map'
,p_mime_type=>'application/json'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '76617220464F533D77696E646F772E464F537C7C7B7D3B464F532E657865633D464F532E657865637C7C7B7D2C464F532E657865632E6372656174654E65737465644F626A656374416E6441737369676E3D66756E6374696F6E28652C742C73297B666F';
wwv_flow_api.g_varchar2_table(2) := '722876617220612C693D742E73706C697428222E22292C6E3D692E6C656E6774682D312C723D303B723C6E3B2B2B722928613D695B725D29696E20657C7C28655B615D3D7B7D292C653D655B615D3B655B695B6E5D5D3D737D2C464F532E657865632E70';
wwv_flow_api.g_varchar2_table(3) := '6C73716C3D66756E6374696F6E28652C742C73297B76617220612C693D2264616E676572222C6E3D226572726F72222C723D22696E666F222C6F3D2273756363657373222C6C3D227761726E696E67223B617065782E64656275672E696E666F2822464F';
wwv_flow_api.g_varchar2_table(4) := '53202D204578656375746520504C2F53514C20436F6465222C74292C613D7B6469736D6973733A5B226F6E436C69636B222C226F6E427574746F6E225D2C6469736D69737341667465723A3565332C6E65776573744F6E546F703A21302C70726576656E';
wwv_flow_api.g_varchar2_table(5) := '744475706C6963617465733A21312C65736361706548746D6C3A21312C706F736974696F6E3A22746F702D7269676874222C69636F6E436C6173733A6E756C6C2C636C656172416C6C3A21317D2C7320696E7374616E63656F662046756E6374696F6E26';
wwv_flow_api.g_varchar2_table(6) := '26732E63616C6C28652C742C61293B76617220632C752C702C6D2C662C642C672C622C783D652E6166666563746564456C656D656E74732C683D652E726573756D6543616C6C6261636B2C763D742E616A617849642C793D742E706167654974656D732C';
wwv_flow_api.g_varchar2_table(7) := '773D742E7370696E6E657253657474696E67732C453D742E636C6F6253657474696E67732C433D742E6F7074696F6E733B696628452E7375626D6974436C6F622973776974636828452E7375626D6974436C6F6246726F6D297B63617365227061676569';
wwv_flow_api.g_varchar2_table(8) := '74656D223A6D3D617065782E6974656D28452E7375626D6974436C6F624974656D292E67657456616C756528293B627265616B3B63617365226A6176617363726970747661726961626C65223A76617220533D452E7375626D6974436C6F625661726961';
wwv_flow_api.g_varchar2_table(9) := '626C652E73706C697428222E22292E726564756365282866756E6374696F6E28652C74297B72657475726E20653F2E5B745D7D292C77696E646F77293B6D3D5320696E7374616E63656F66204F626A6563743F4A534F4E2E737472696E67696679285329';
wwv_flow_api.g_varchar2_table(10) := '3A533B627265616B3B63617365226A617661736372697074696E6974223A2266756E6374696F6E223D3D747970656F6620742E7375626D6974436C6F623F6D3D742E7375626D6974436C6F622E63616C6C2874293A617065782E64656275672E7761726E';
wwv_flow_api.g_varchar2_table(11) := '28272E2E2E2E204572726F7220227375626D6974436C6F62222066756E6374696F6E206973206D697373696E672066726F6D2074686520636F6E666967206F7074696F6E732E20596F75206D75737420646566696E6520746869732066756E6374696F6E';
wwv_flow_api.g_varchar2_table(12) := '20696E2074686520224A61766173637269707420496E697469616C697A6174696F6E20436F6465222061747472696275746520696E20796F75722064796E616D696320616374696F6E2127297D772E73686F775370696E6E6572262628772E7370696E6E';
wwv_flow_api.g_varchar2_table(13) := '6572456C656D656E743D772E73686F775370696E6E65724F6E526567696F6E3F783A22626F6479222C643D772E7370696E6E6572456C656D656E742C673D772E73686F775370696E6E65724F7665726C61792C623D22626F6479223D3D642C663D66756E';
wwv_flow_api.g_varchar2_table(14) := '6374696F6E2865297B76617220742C733D617065782E7574696C2E73686F775370696E6E657228642C7B66697865643A627D293B72657475726E2067262628743D2428273C64697620636C6173733D22666F732D726567696F6E2D6F7665726C6179272B';
wwv_flow_api.g_varchar2_table(15) := '28623F222D6669786564223A2222292B27223E3C2F6469763E27292E70726570656E64546F286429292C66756E6374696F6E28297B742626742E72656D6F766528292C732E72656D6F766528297D7D292C50726F6D6973652E7265736F6C7665286D292E';
wwv_flow_api.g_varchar2_table(16) := '7468656E282866756E6374696F6E2873297B617065782E7365727665722E706C7567696E28762C7B706167654974656D733A792E6974656D73546F5375626D69742C705F636C6F625F30313A737D2C7B64617461547970653A226A736F6E222C6C6F6164';
wwv_flow_api.g_varchar2_table(17) := '696E67496E64696361746F723A662C7461726765743A652E62726F777365724576656E742E7461726765747D292E646F6E65282866756E6374696F6E2865297B2166756E6374696F6E2865297B696628652E7374617475733D3D6F297B76617220732C6D';
wwv_flow_api.g_varchar2_table(18) := '2C663D21313B696628663D2121652E63616E63656C416374696F6E732C652626652E6974656D73297B733D286D3D652E6974656D73292E6C656E6774683B666F722876617220643D303B643C733B642B2B296D5B645D2E646973706C61793F2473286D5B';
wwv_flow_api.g_varchar2_table(19) := '645D2E69642C6D5B645D2E76616C75652C6D5B645D2E646973706C61792C432E73757070726573734368616E67654576656E74293A2473286D5B645D2E69642C6D5B645D2E76616C75652C6E756C6C2C432E73757070726573734368616E67654576656E';
wwv_flow_api.g_varchar2_table(20) := '74297D696628452E72657475726E436C6F622973776974636828452E72657475726E436C6F62496E746F297B6361736522706167656974656D223A247328452E72657475726E436C6F624974656D2C652E636C6F622C6E756C6C2C432E73757070726573';
wwv_flow_api.g_varchar2_table(21) := '734368616E67654576656E74293B627265616B3B63617365226A6176617363726970747661726961626C65223A464F532E657865632E6372656174654E65737465644F626A656374416E6441737369676E2877696E646F772C452E72657475726E436C6F';
wwv_flow_api.g_varchar2_table(22) := '625661726961626C652C652E636C6F62293B627265616B3B63617365226A6176617363726970747661726961626C656A736F6E223A652E65786563506C73716C526573756C743D4A534F4E2E706172736528652E636C6F62292C464F532E657865632E63';
wwv_flow_api.g_varchar2_table(23) := '72656174654E65737465644F626A656374416E6441737369676E2877696E646F772C452E72657475726E436C6F625661726961626C652C652E65786563506C73716C526573756C74292C66756E6374696F6E2865297B76617220743D7B68696465526567';
wwv_flow_api.g_varchar2_table(24) := '696F6E733A66756E6374696F6E2865297B7472797B617065782E726567696F6E2865292E656C656D656E742E6869646528297D63617463682874297B617065782E64656275672E7761726E28222E2E2E2E204572726F7220686964696E67207468652066';
wwv_flow_api.g_varchar2_table(25) := '6F6C6C6F77696E6720726567696F6E3A20222B652C74297D7D2C73686F77526567696F6E733A66756E6374696F6E2865297B7472797B617065782E726567696F6E2865292E656C656D656E742E73686F7728297D63617463682874297B617065782E6465';
wwv_flow_api.g_varchar2_table(26) := '6275672E7761726E28222E2E2E2E204572726F722073686F77696E672074686520666F6C6C6F77696E6720726567696F6E3A20222B652C74297D7D2C686964654974656D733A66756E6374696F6E2865297B617065782E6974656D2865292E6869646528';
wwv_flow_api.g_varchar2_table(27) := '297D2C73686F774974656D733A66756E6374696F6E2865297B617065782E6974656D2865292E73686F7728297D2C656E61626C654974656D733A66756E6374696F6E2865297B617065782E6974656D2865292E656E61626C6528297D2C64697361626C65';
wwv_flow_api.g_varchar2_table(28) := '4974656D733A66756E6374696F6E2865297B617065782E6974656D2865292E64697361626C6528297D2C68696465427574746F6E733A66756E6374696F6E2865297B617065782E6A5175657279282223222B65292E6869646528297D2C73686F77427574';
wwv_flow_api.g_varchar2_table(29) := '746F6E733A66756E6374696F6E2865297B617065782E6A5175657279282223222B65292E73686F7728297D2C656E61626C65427574746F6E733A66756E6374696F6E2865297B617065782E6A5175657279282223222B65292E6174747228226469736162';
wwv_flow_api.g_varchar2_table(30) := '6C6564222C2131297D2C64697361626C65427574746F6E733A66756E6374696F6E2865297B617065782E6A5175657279282223222B65292E61747472282264697361626C6564222C2130297D2C73657456616C7565733A66756E6374696F6E2865297B24';
wwv_flow_api.g_varchar2_table(31) := '7328652E6E616D652C652E76616C75652C652E646973706C61792C652E73757070726573734368616E67654576656E74297D2C636C6561724572726F72733A66756E6374696F6E28297B617065782E6D6573736167652E636C6561724572726F72732829';
wwv_flow_api.g_varchar2_table(32) := '7D2C6974656D4572726F72733A66756E6374696F6E2865297B76617220743D617065782E7574696C2E6170706C7954656D706C61746528652E6D6573736167652C7B64656661756C7445736361706546696C7465723A6E756C6C7D293B617065782E6D65';
wwv_flow_api.g_varchar2_table(33) := '73736167652E73686F774572726F7273287B747970653A6E2C6C6F636174696F6E3A652E6C6F636174696F6E7C7C5B22696E6C696E65222C2270616765225D2C706167654974656D3A652E6E616D652C6D6573736167653A742C756E736166653A21317D';
wwv_flow_api.g_varchar2_table(34) := '297D2C72656672657368526567696F6E733A66756E6374696F6E2865297B7472797B617065782E726567696F6E2865292E7265667265736828297D63617463682874297B617065782E64656275672E7761726E28222E2E2E2E204572726F722072656672';
wwv_flow_api.g_varchar2_table(35) := '657368696E672074686520666F6C6C6F77696E6720726567696F6E3A20222B652C74297D7D2C726566726573684974656D733A66756E6374696F6E2865297B7472797B617065782E6974656D2865292E7265667265736828297D63617463682874297B61';
wwv_flow_api.g_varchar2_table(36) := '7065782E64656275672E7761726E28222E2E2E2E204572726F722072656672657368696E672074686520666F6C6C6F77696E67206974656D3A20222B652C74297D7D2C666972654576656E74733A66756E6374696F6E2865297B617065782E6576656E74';
wwv_flow_api.g_varchar2_table(37) := '2E7472696767657228652E73656C6563746F727C7C22626F6479222C652E6E616D652C652E64617461297D2C72656D6F7665436C6173733A66756E6374696F6E2865297B617065782E6A517565727928652E73656C6563746F72292E72656D6F7665436C';
wwv_flow_api.g_varchar2_table(38) := '61737328652E636C617373297D2C616464436C6173733A66756E6374696F6E2865297B617065782E6A517565727928652E73656C6563746F72292E616464436C61737328652E636C617373297D7D3B6966284F626A6563742E656E74726965732874292E';
wwv_flow_api.g_varchar2_table(39) := '666F7245616368282866756E6374696F6E2874297B76617220733D745B305D2C613D745B315D3B7320696E2065262641727261792E6973417272617928655B735D293F655B735D2E666F72456163682861293A7320696E206526265B22626F6F6C65616E';
wwv_flow_api.g_varchar2_table(40) := '222C226E756D626572222C22737472696E67225D2E696E636C7564657328747970656F6620655B735D292626612E63616C6C28652C655B735D297D29292C652E736574466F6375734974656D297472797B617065782E6974656D28652E736574466F6375';
wwv_flow_api.g_varchar2_table(41) := '734974656D292E736574466F63757328297D63617463682874297B617065782E64656275672E7761726E28222E2E2E2E204572726F722073657474696E6720666F6375732074686520666F6C6C6F77696E67206974656D3A20222B652E736574466F6375';
wwv_flow_api.g_varchar2_table(42) := '734974656D2C74297D7D28652E65786563506C73716C526573756C74293B627265616B3B63617365226A617661736372697074696E697461736A736F6E223A2266756E6374696F6E223D3D747970656F6620742E636C6F6243616C6C6261636B3F28652E';
wwv_flow_api.g_varchar2_table(43) := '65786563506C73716C526573756C743D4A534F4E2E706172736528652E636C6F62292C742E636C6F6243616C6C6261636B2E63616C6C28742C652E65786563506C73716C526573756C7429293A617065782E64656275672E7761726E28272E2E2E2E2045';
wwv_flow_api.g_varchar2_table(44) := '72726F722022636C6F6243616C6C6261636B222066756E6374696F6E206973206D697373696E672066726F6D2074686520636F6E666967206F7074696F6E732E20596F75206D75737420646566696E6520746869732066756E6374696F6E20696E207468';
wwv_flow_api.g_varchar2_table(45) := '6520224A61766173637269707420496E697469616C697A6174696F6E20436F6465222061747472696275746520696E20796F75722064796E616D696320616374696F6E2127297D696628652E65786563506C73716C526573756C74262628652E65786563';
wwv_flow_api.g_varchar2_table(46) := '506C73716C526573756C742E63616E63656C416374696F6E73262628663D2130292C652E65786563506C73716C526573756C742E6E6F74696669636174696F6E29297B76617220673D652E65786563506C73716C526573756C742E6E6F74696669636174';
wwv_flow_api.g_varchar2_table(47) := '696F6E3B652E6D6573736167653D672E6D6573736167652C652E6D657373616765547970653D672E747970652C652E6D6573736167655469746C653D672E7469746C657D652E6D657373616765262628753D28753D652E6D657373616765547970652626';
wwv_flow_api.g_varchar2_table(48) := '5B722C6C2C6F2C6E2C695D2E696E636C7564657328652E6D65737361676554797065293F652E6D657373616765547970653A6F293D3D3D693F6E3A752C703D652E6D6573736167655469746C652C633D652E6D6573736167652C702626432E706572666F';
wwv_flow_api.g_varchar2_table(49) := '726D537562737469747574696F6E73262628703D617065782E7574696C2E6170706C7954656D706C61746528702C7B64656661756C7445736361706546696C7465723A6E756C6C7D29292C632626432E706572666F726D537562737469747574696F6E73';
wwv_flow_api.g_varchar2_table(50) := '262628633D617065782E7574696C2E6170706C7954656D706C61746528632C7B64656661756C7445736361706546696C7465723A6E756C6C7D29292C702626432E6573636170654D657373616765262628703D617065782E7574696C2E65736361706548';
wwv_flow_api.g_varchar2_table(51) := '544D4C287029292C632626432E6573636170654D657373616765262628633D617065782E7574696C2E65736361706548544D4C286329292C242E657874656E6428612C7B6D6573736167653A703F633A766F696420302C7469746C653A707C7C632C7479';
wwv_flow_api.g_varchar2_table(52) := '70653A752C6469736D69737341667465723A753D3D3D6E3F766F696420303A612E6469736D69737341667465727D292C666F7374725B755D286129292C652E6576656E744E616D652626617065782E6576656E742E747269676765722822626F6479222C';
wwv_flow_api.g_varchar2_table(53) := '652E6576656E744E616D652C65292C617065782E64612E726573756D6528682C66297D656C736520652E7374617475733D3D6E262628652E6D657373616765262628703D652E6D6573736167655469746C652C633D652E6D6573736167652C702626432E';
wwv_flow_api.g_varchar2_table(54) := '706572666F726D537562737469747574696F6E73262628703D617065782E7574696C2E6170706C7954656D706C61746528702C7B64656661756C7445736361706546696C7465723A6E756C6C7D29292C632626432E706572666F726D5375627374697475';
wwv_flow_api.g_varchar2_table(55) := '74696F6E73262628633D617065782E7574696C2E6170706C7954656D706C61746528632C7B64656661756C7445736361706546696C7465723A6E756C6C7D29292C702626432E6573636170654D657373616765262628703D617065782E7574696C2E6573';
wwv_flow_api.g_varchar2_table(56) := '6361706548544D4C287029292C632626432E6573636170654D657373616765262628633D617065782E7574696C2E65736361706548544D4C286329292C432E73686F774572726F724173416C6572743F617065782E6D6573736167652E616C6572742863';
wwv_flow_api.g_varchar2_table(57) := '293A28242E657874656E6428612C7B6D6573736167653A703F633A766F696420302C7469746C653A707C7C632C747970653A6E2C6469736D69737341667465723A766F696420307D292C666F7374722E6572726F722861292C652E6576656E744E616D65';
wwv_flow_api.g_varchar2_table(58) := '2626617065782E6576656E742E747269676765722822626F6479222C652E6576656E744E616D652C652929292C617065782E64612E726573756D6528682C213029297D2865297D29292E6661696C282866756E6374696F6E28652C742C73297B61706578';
wwv_flow_api.g_varchar2_table(59) := '2E64612E68616E646C65416A61784572726F727328652C742C732C68297D29297D29292E6361746368282866756E6374696F6E2865297B617065782E6465627567282223234552524F52232320464F532E457865637574652E504C53514C222C65292C61';
wwv_flow_api.g_varchar2_table(60) := '7065782E64612E68616E646C65416A61784572726F7273287B7374617475733A3939397D2C22464F532E457865637574652E504C53514C222C652C68297D29297D3B0A2F2F2320736F757263654D617070696E6755524C3D7363726970742E6A732E6D61';
wwv_flow_api.g_varchar2_table(61) := '70';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(8448341494481327)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_file_name=>'js/script.min.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C22736F7572636573223A5B227363726970742E6A73225D2C226E616D6573223A5B22464F53222C2277696E646F77222C2265786563222C226372656174654E65737465644F626A656374416E6441737369676E222C226F';
wwv_flow_api.g_varchar2_table(2) := '626A222C226B657950617468222C2276616C7565222C226B6579222C226B657950617468417272222C2273706C6974222C226C6173744B6579496E646578222C226C656E677468222C2269222C22706C73716C222C226461436F6E74657874222C22636F';
wwv_flow_api.g_varchar2_table(3) := '6E666967222C22696E6974466E222C22666F7374724F7074696F6E73222C22435F44414E474552222C22435F4552524F52222C22435F494E464F222C22435F53554343455353222C22435F5741524E494E47222C2261706578222C226465627567222C22';
wwv_flow_api.g_varchar2_table(4) := '696E666F222C226469736D697373222C226469736D6973734166746572222C226E65776573744F6E546F70222C2270726576656E744475706C696361746573222C2265736361706548746D6C222C22706F736974696F6E222C2269636F6E436C61737322';
wwv_flow_api.g_varchar2_table(5) := '2C22636C656172416C6C222C2246756E6374696F6E222C2263616C6C222C226D657373616765222C226D65737361676554797065222C226D6573736167655469746C65222C22636C6F62546F5375626D6974222C226C6F6164696E67496E64696361746F';
wwv_flow_api.g_varchar2_table(6) := '72466E222C22656C656D656E74222C2273686F774F7665726C6179222C2266697865644F6E426F6479222C226166456C656D656E7473222C226166666563746564456C656D656E7473222C22726573756D6543616C6C6261636B222C22616A6178496422';
wwv_flow_api.g_varchar2_table(7) := '2C22706167654974656D73222C227370696E6E657253657474696E6773222C22636C6F6253657474696E6773222C226F7074696F6E73222C227375626D6974436C6F62222C227375626D6974436C6F6246726F6D222C226974656D222C227375626D6974';
wwv_flow_api.g_varchar2_table(8) := '436C6F624974656D222C2267657456616C7565222C22746F5375626D6974222C227375626D6974436C6F625661726961626C65222C22726564756365222C22616363222C2270617468222C224F626A656374222C224A534F4E222C22737472696E676966';
wwv_flow_api.g_varchar2_table(9) := '79222C227761726E222C2273686F775370696E6E6572222C227370696E6E6572456C656D656E74222C2273686F775370696E6E65724F7665726C6179222C22704C6F6164696E67496E64696361746F72222C226F7665726C617924222C227370696E6E65';
wwv_flow_api.g_varchar2_table(10) := '7224222C227574696C222C226669786564222C2224222C2270726570656E64546F222C2272656D6F7665222C2250726F6D697365222C227265736F6C7665222C227468656E222C22736572766572222C22706C7567696E222C226974656D73546F537562';
wwv_flow_api.g_varchar2_table(11) := '6D6974222C22705F636C6F625F3031222C226461746154797065222C226C6F6164696E67496E64696361746F72222C22746172676574222C2262726F777365724576656E74222C22646F6E65222C2264617461222C227044617461222C22737461747573';
wwv_flow_api.g_varchar2_table(12) := '222C226974656D436F756E74222C226974656D4172726179222C2263616E63656C416374696F6E73222C226974656D73222C22646973706C6179222C222473222C226964222C2273757070726573734368616E67654576656E74222C2272657475726E43';
wwv_flow_api.g_varchar2_table(13) := '6C6F62222C2272657475726E436C6F62496E746F222C2272657475726E436C6F624974656D222C22636C6F62222C2272657475726E436C6F625661726961626C65222C2265786563506C73716C526573756C74222C227061727365222C22616374696F6E';
wwv_flow_api.g_varchar2_table(14) := '46756E74696F6E73222C2268696465526567696F6E73222C22726567696F6E222C2268696465222C2265222C2273686F77526567696F6E73222C2273686F77222C22686964654974656D73222C2273686F774974656D73222C22656E61626C654974656D';
wwv_flow_api.g_varchar2_table(15) := '73222C22656E61626C65222C2264697361626C654974656D73222C2264697361626C65222C2268696465427574746F6E73222C22627574746F6E222C226A5175657279222C2273686F77427574746F6E73222C22656E61626C65427574746F6E73222C22';
wwv_flow_api.g_varchar2_table(16) := '61747472222C2264697361626C65427574746F6E73222C2273657456616C756573222C226E616D65222C22636C6561724572726F7273222C226974656D4572726F7273222C226170706C7954656D706C617465222C2264656661756C7445736361706546';
wwv_flow_api.g_varchar2_table(17) := '696C746572222C2273686F774572726F7273222C2274797065222C226C6F636174696F6E222C22706167654974656D222C22756E73616665222C2272656672657368526567696F6E73222C2272656672657368222C22726566726573684974656D73222C';
wwv_flow_api.g_varchar2_table(18) := '22666972654576656E7473222C226576656E74222C2274726967676572222C2273656C6563746F72222C2272656D6F7665436C617373222C22636C617373222C22616464436C617373222C22656E7472696573222C22666F7245616368222C2261637469';
wwv_flow_api.g_varchar2_table(19) := '6F6E222C226D6574686F64222C22666E222C224172726179222C2269734172726179222C22696E636C75646573222C22736574466F6375734974656D222C22736574466F637573222C225F706572666F726D416374696F6E73222C22636C6F6243616C6C';
wwv_flow_api.g_varchar2_table(20) := '6261636B222C226E6F74696669636174696F6E222C227469746C65222C22706572666F726D537562737469747574696F6E73222C226573636170654D657373616765222C2265736361706548544D4C222C22657874656E64222C22756E646566696E6564';

wwv_flow_api.g_varchar2_table(21) := '222C22666F737472222C226576656E744E616D65222C226461222C22726573756D65222C2273686F774572726F724173416C657274222C22616C657274222C226572726F72222C225F68616E646C65526573706F6E7365222C226661696C222C226A7158';
wwv_flow_api.g_varchar2_table(22) := '4852222C2274657874537461747573222C226572726F725468726F776E222C2268616E646C65416A61784572726F7273222C226361746368222C22657272225D2C226D617070696E6773223A22414145412C49414149412C4941414D432C4F41414F442C';
wwv_flow_api.g_varchar2_table(23) := '4B41414F2C4741437842412C49414149452C4B41414F462C49414149452C4D4141512C4741537642462C49414149452C4B41414B432C3442414138422C53414155432C4541414B432C45414153432C47414933442C494148412C49414549432C45414641';
wwv_flow_api.g_varchar2_table(24) := '432C45414161482C45414151492C4D41414D2C4B41433342432C45414165462C45414157472C4F4141532C4541453942432C454141492C45414147412C45414149462C4941416742452C47414368434C2C4541414D432C45414157492C4D41434A522C49';
wwv_flow_api.g_varchar2_table(25) := '414354412C45414149472C4741414F2C49414566482C4541414D412C45414149472C47414564482C45414149492C45414157452C49414169424A2C4741364270434E2C49414149452C4B41414B572C4D4141512C53414155432C45414157432C45414151';
wwv_flow_api.g_varchar2_table(26) := '432C47414531432C49414D49432C45414E41432C454141572C53414358432C454141552C51414356432C454141532C4F414354432C454141592C5541435A432C454141592C5541476842432C4B41414B432C4D41414D432C4B41414B2C34424141364256';
wwv_flow_api.g_varchar2_table(27) := '2C4741453743452C454141652C43414358532C514141532C434141432C554141572C5941437242432C614141632C49414364432C614141612C45414362432C6D4241416D422C4541436E42432C594141592C4541435A432C534141552C59414356432C55';
wwv_flow_api.g_varchar2_table(28) := '4141572C4B414358432C554141552C47414B566A422C6141416B426B422C5541436C426C422C4541414F6D422C4B41414B72422C45414157432C45414151452C4741476E432C49414F496D422C45414153432C45414161432C45416F517442432C454134';
wwv_flow_api.g_varchar2_table(29) := '4241432C45414D6743432C45414153432C4541436A43432C4541395352432C4541416139422C454141552B422C694241437642432C454141694268432C4541415567432C6541433342432C4541415368432C4541414F67432C4F41436842432C45414159';
wwv_flow_api.g_varchar2_table(30) := '6A432C4541414F69432C5541436E42432C4541416B426C432C4541414F6B432C674241437A42432C454141656E432C4541414F6D432C6141437442432C4541415570432C4541414F6F432C5141755172422C47414149442C45414161452C574143622C4F';
wwv_flow_api.g_varchar2_table(31) := '414151462C45414161472C674241436A422C4941414B2C57414344642C4541416568422C4B41414B2B422C4B41414B4A2C454141614B2C674241416742432C57414374442C4D41434A2C4941414B2C71424143442C49414149432C4541417142502C4541';
wwv_flow_api.g_varchar2_table(32) := '4161512C6D424176516C436A442C4D41414D2C4B41414B6B442C5141414F2C53414153432C45414149432C47414376432C4F41414F442C4941414D432C4B41436435442C514177515373432C454144416B422C6141416F424B2C4F41434C432C4B41414B';
wwv_flow_api.g_varchar2_table(33) := '432C55414155502C47414566412C4541456E422C4D41434A2C4941414B2C6942414367432C6D424141744231432C4541414F71432C57414364622C4541416578422C4541414F71432C574141576A422C4B41414B70422C4741457443512C4B41414B432C';
wwv_flow_api.g_varchar2_table(34) := '4D41414D79432C4B41414B2C674C4157354268422C454141674269422C63414568426A422C45414167426B422C6541416B426C422C4541416D432C6F424141494C2C454141612C4F41437444482C454169423742512C45414167426B422C65416A427342';
wwv_flow_api.g_varchar2_table(35) := '7A422C454169424E4F2C45414167426D422C6D4241684233437A422C45414179422C51414158462C4541447442442C454145572C5341415536422C474143622C49414149432C45414341432C4541415768442C4B41414B69442C4B41414B4E2C59414159';
wwv_flow_api.g_varchar2_table(36) := '7A422C454141532C4341414567432C4D41414F39422C49415776442C4F415649442C4941434134422C45414157492C454141452C6B4341416F432F422C454141632C534141572C4941414D2C5941415967432C554141556C432C49414531472C57414351';
wwv_flow_api.g_varchar2_table(37) := '36422C47414341412C454141534D2C534145624C2C454141534B2C5941557A42432C51414151432C5141415176432C4741416377432C4D41414B2C534141557A452C474145354269422C4B41414B79442C4F41414F432C4F41414F6C432C454141512C43';
wwv_flow_api.g_varchar2_table(38) := '41437043432C55414157412C454141556B432C6341437242432C5541415737452C4741435A2C4341434338452C534141552C4F414356432C694241416B4237432C4541436C4238432C4F41415178452C4541415579452C61414161442C5341493542452C';
wwv_flow_api.g_varchar2_table(39) := '4D41414B2C53414155432C4941395431422C5341417942432C4741344772422C47414149412C4541414D432C5141415574452C454141572C43414333422C4941414975452C45414157432C45414157432C47414167422C45414D31432C47414841412C49';
wwv_flow_api.g_varchar2_table(40) := '41416B424A2C4541414D492C63414770424A2C47414153412C4541414D4B2C4D41414F2C4341457442482C47414441432C45414159482C4541414D4B2C4F41434970462C4F414374422C4941414B2C49414149432C454141492C45414147412C45414149';
wwv_flow_api.g_varchar2_table(41) := '67462C4541415768462C494143764269462C454141556A462C474141476F462C51414362432C474141474A2C454141556A462C4741414773462C474141494C2C454141556A462C474141474E2C4D41414F75462C454141556A462C474141476F462C5141';
wwv_flow_api.g_varchar2_table(42) := '415337432C4541415167442C714241457445462C474141474A2C454141556A462C4741414773462C474141494C2C454141556A462C474141474E2C4D41414F2C4B41414D36432C4541415167442C7142414F6C452C474141496A442C454141616B442C57';
wwv_flow_api.g_varchar2_table(43) := '4143622C4F4141516C442C454141616D442C674241436A422C4941414B2C574143444A2C474141472F432C454141616F442C65414167425A2C4541414D612C4B41414D2C4B41414D70442C4541415167442C7142414331442C4D41434A2C4941414B2C71';
wwv_flow_api.g_varchar2_table(44) := '424143446E472C49414149452C4B41414B432C344241413442462C4F41415169442C4541416173442C6D4241416F42642C4541414D612C4D414370462C4D41434A2C4941414B2C7942414344622C4541414D652C674241416B4231432C4B41414B32432C';
wwv_flow_api.g_varchar2_table(45) := '4D41414D68422C4541414D612C4D41437A4376472C49414149452C4B41414B432C344241413442462C4F41415169442C4541416173442C6D4241416F42642C4541414D652C694241314970472C5341417942662C47414572422C4941414969422C454141';
wwv_flow_api.g_varchar2_table(46) := '69422C4341436A42432C594141612C53414155432C4741436E422C4941434974462C4B41414B73462C4F41414F412C4741415170452C5141415171452C4F414339422C4D41414F432C4741434C78462C4B41414B432C4D41414D79432C4B41414B2C3243';
wwv_flow_api.g_varchar2_table(47) := '4141364334432C45414151452C4B41473745432C594141612C53414155482C4741436E422C4941434974462C4B41414B73462C4F41414F412C4741415170452C5141415177452C4F414339422C4D41414F462C4741434C78462C4B41414B432C4D41414D';
wwv_flow_api.g_varchar2_table(48) := '79432C4B41414B2C34434141384334432C45414151452C4B41473945472C554141572C5341415535442C4741436A422F422C4B41414B2B422C4B41414B412C4741414D77442C51414570424B2C554141572C5341415537442C4741436A422F422C4B4141';
wwv_flow_api.g_varchar2_table(49) := '4B2B422C4B41414B412C4741414D32442C5141457042472C594141612C5341415539442C4741436E422F422C4B41414B2B422C4B41414B412C4741414D2B442C5541457042432C614141632C5341415568452C47414370422F422C4B41414B2B422C4B41';
wwv_flow_api.g_varchar2_table(50) := '414B412C4741414D69452C5741457042432C594141612C53414155432C4741436E426C472C4B41414B6D472C4F41414F2C4941414D442C47414151582C5141453942612C594141612C53414155462C4741436E426C472C4B41414B6D472C4F41414F2C49';
wwv_flow_api.g_varchar2_table(51) := '41414D442C47414151522C5141453942572C634141652C53414155482C47414372426C472C4B41414B6D472C4F41414F2C4941414D442C47414151492C4B41414B2C594141592C4941452F43432C65414167422C534141554C2C47414374426C472C4B41';
wwv_flow_api.g_varchar2_table(52) := '414B6D472C4F41414F2C4941414D442C47414151492C4B41414B2C594141592C4941452F43452C554141572C534141557A452C4741436A4232432C4741414733432C4541414B30452C4B41414D31452C4541414B68442C4D41414F67442C4541414B3043';
wwv_flow_api.g_varchar2_table(53) := '2C5141415331432C4541414B36432C734241456A4438422C594141612C5741435431472C4B41414B612C5141415136462C6541456A42432C574141592C5341415535452C4741436C422C494141496C422C45414155622C4B41414B69442C4B41414B3244';
wwv_flow_api.g_varchar2_table(54) := '2C6341416337452C4541414B6C422C514141532C434143684467472C6F42414171422C4F41457A4237472C4B41414B612C5141415169472C574141572C4341437042432C4B41414D6E482C4541434E6F482C534141556A462C4541414B69462C55414159';
wwv_flow_api.g_varchar2_table(55) := '2C434141432C534141552C5141437443432C534141556C462C4541414B30452C4B41436635462C51414153412C4541455471472C514141512C4B41476842432C65414167422C5341415537422C47414374422C4941434974462C4B41414B73462C4F4141';
wwv_flow_api.g_varchar2_table(56) := '4F412C4741415138422C55414374422C4D41414F35422C4741434C78462C4B41414B432C4D41414D79432C4B41414B2C2B434141694434432C45414151452C4B41476A4636422C614141632C5341415574462C47414370422C494143492F422C4B41414B';
wwv_flow_api.g_varchar2_table(57) := '2B422C4B41414B412C4741414D71462C5541436C422C4D41414F35422C4741434C78462C4B41414B432C4D41414D79432C4B41414B2C364341412B43582C4541414D79442C4B4147374538422C574141592C5341415539422C4741436C4278462C4B4141';
wwv_flow_api.g_varchar2_table(58) := '4B75482C4D41414D432C5141415168432C4541414569432C554141592C4F4141516A432C4541414569422C4B41414D6A422C4541414574422C4F4145764477442C594141612C5341415533462C4741436E422F422C4B41414B6D472C4F41414F70452C45';
wwv_flow_api.g_varchar2_table(59) := '41414B30462C55414155432C5941415933462C4541414B34462C5141456844432C534141552C5341415537462C47414368422F422C4B41414B6D472C4F41414F70452C4541414B30462C55414155472C5341415337462C4541414B34462C5341656A442C';
wwv_flow_api.g_varchar2_table(60) := '4741584170462C4F41414F73462C514141517A432C474141674230432C534141512C53414155432C47414337432C49414149432C45414153442C4541414F2C4741436842452C4541414B462C4541414F2C4741435A432C4B41415537442C474141532B44';
wwv_flow_api.g_varchar2_table(61) := '2C4D41414D432C5141415168452C4541414D36442C494143764337442C4541414D36442C47414151462C51414151472C47414366442C4B41415537442C474141532C434141432C554141572C534141552C5541415569452C6742414167426A452C454141';
wwv_flow_api.g_varchar2_table(62) := '4D36442C4B41436846432C4541414772482C4B41414B75442C4541414F412C4541414D36442C4F414B7A4237442C4541414D6B452C6141434E2C4941434972492C4B41414B2B422C4B41414B6F432C4541414D6B452C63414163432C57414368432C4D41';
wwv_flow_api.g_varchar2_table(63) := '414F39432C4741434C78462C4B41414B432C4D41414D79432C4B41414B2C674441416B4479422C4541414D6B452C6141416337432C494175436C462B432C434141674270452C4541414D652C6942414374422C4D41434A2C4941414B2C754241436B432C';
wwv_flow_api.g_varchar2_table(64) := '6D424141784231462C4541414F674A2C6341436472452C4541414D652C674241416B4231432C4B41414B32432C4D41414D68422C4541414D612C4D41437A4378462C4541414F674A2C6141416135482C4B41414B70422C4541415132452C4541414D652C';
wwv_flow_api.g_varchar2_table(65) := '6B42414576436C462C4B41414B432C4D41414D79432C4B41414B2C6B4C414F68432C4741414979422C4541414D652C6B42414346662C4541414D652C674241416742582C674241437442412C47414167422C47414568424A2C4541414D652C6742414167';
wwv_flow_api.g_varchar2_table(66) := '4275442C634141632C43414370432C49414149412C4541416574452C4541414D652C67424141674275442C6141437A4374452C4541414D74442C5141415534482C4541416135482C514143374273442C4541414D72442C5941416332482C454141613142';
wwv_flow_api.g_varchar2_table(67) := '2C4B41436A4335432C4541414D70442C6141416530482C45414161432C4D414B744376452C4541414D74442C5541454E432C47414441412C4541416571442C4541414D72442C614141652C434141436A422C45414151452C45414157442C45414157462C';
wwv_flow_api.g_varchar2_table(68) := '45414153442C4741415579492C534141536A452C4541414D72442C614141674271442C4541414D72442C5941416368422C4B41433147482C45414159432C454141556B422C4541457244432C454141656F442C4541414D70442C6141437242462C454141';
wwv_flow_api.g_varchar2_table(69) := '5573442C4541414D74442C5141475A452C4741416742612C454141512B472C75424143784235482C45414165662C4B41414B69442C4B41414B32442C6341416337462C454141632C4341414538462C6F42414171422C514145354568472C47414157652C';
wwv_flow_api.g_varchar2_table(70) := '454141512B472C754241436E4239482C45414155622C4B41414B69442C4B41414B32442C634141632F462C454141532C4341414567472C6F42414171422C5141496C4539462C4741416742612C4541415167482C67424143784237482C45414165662C4B';
wwv_flow_api.g_varchar2_table(71) := '41414B69442C4B41414B34462C5741415739482C4941457043462C47414157652C4541415167482C674241436E422F482C45414155622C4B41414B69442C4B41414B34462C5741415768492C4941496E4373432C4541414532462C4F41414F704A2C4541';
wwv_flow_api.g_varchar2_table(72) := '41632C4341436E426D422C514141532C4541416942412C4F4141556B492C45414370434C2C4D41415333482C4741416742462C4541437A426B472C4B41414D6A472C4541434E562C61414165552C49414167426C422C4F4141576D4A2C45414159724A2C';
wwv_flow_api.g_varchar2_table(73) := '45414161552C654145764534492C4D41414D6C492C4741416170422C4941476E4279452C4541414D38452C5741434E6A4A2C4B41414B75482C4D41414D432C514141512C4F41415172442C4541414D38452C5541415739452C47414B68446E452C4B4141';
wwv_flow_api.g_varchar2_table(74) := '4B6B4A2C47414147432C4F41414F35482C454141674267442C51414378424A2C4541414D432C5141415578452C4941436E4275452C4541414D74442C5541454E452C454141656F442C4541414D70442C6141437242462C4541415573442C4541414D7444';
wwv_flow_api.g_varchar2_table(75) := '2C5141455A452C4741416742612C454141512B472C75424143784235482C45414165662C4B41414B69442C4B41414B32442C6341416337462C454141632C4341414538462C6F42414171422C514145354568472C47414157652C454141512B472C754241';
wwv_flow_api.g_varchar2_table(76) := '436E4239482C45414155622C4B41414B69442C4B41414B32442C634141632F462C454141532C4341414567472C6F42414171422C5141496C4539462C4741416742612C4541415167482C67424143784237482C45414165662C4B41414B69442C4B41414B';
wwv_flow_api.g_varchar2_table(77) := '34462C5741415739482C4941457043462C47414157652C4541415167482C674241436E422F482C45414155622C4B41414B69442C4B41414B34462C5741415768492C4941472F42652C4541415177482C6942414352704A2C4B41414B612C514141517749';
wwv_flow_api.g_varchar2_table(78) := '2C4D41414D78492C4941456E4273432C4541414532462C4F41414F704A2C454141632C4341436E426D422C514141532C4541416942412C4F4141556B492C45414370434C2C4D41415333482C4741416742462C4541437A426B472C4B41414D6E482C4541';
wwv_flow_api.g_varchar2_table(79) := '434E512C6B4241416332492C4941456C42432C4D41414D4D2C4D41414D354A2C4741475279452C4541414D38452C5741434E6A4A2C4B41414B75482C4D41414D432C514141512C4F41415172442C4541414D38452C5541415739452C4B414B78446E452C';
wwv_flow_api.g_varchar2_table(80) := '4B41414B6B4A2C47414147432C4F41414F35482C47414167422C494179452F4267492C434141674272462C4D41436A4273462C4D41414B2C53414155432C4541414F432C45414159432C4741436A43334A2C4B41414B6B4A2C47414147552C6942414169';
wwv_flow_api.g_varchar2_table(81) := '42482C4541414F432C45414159432C4541416170492C534145394473492C4F41414D2C53414155432C47414366394A2C4B41414B432C4D41414D2C384241412B42364A2C4741433143394A2C4B41414B6B4A2C47414147552C6942414169422C43414145';
wwv_flow_api.g_varchar2_table(82) := '78462C4F4141512C4B41414F2C6F424141714230462C4541414B7649222C2266696C65223A227363726970742E6A73227D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(8448780994481328)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_file_name=>'js/script.js.map'
,p_mime_type=>'application/json'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '77696E646F772E666F7374723D66756E6374696F6E28297B76617220653D22666F7374722D636F6E7461696E6572222C743D2273756363657373222C6E3D22696E666F222C733D227761726E696E67222C693D226572726F72222C6F3D7B737563636573';
wwv_flow_api.g_varchar2_table(2) := '733A2266612D636865636B2D636972636C65222C696E666F3A2266612D696E666F2D636972636C65222C7761726E696E673A2266612D6578636C616D6174696F6E2D747269616E676C65222C6572726F723A2266612D74696D65732D636972636C65227D';
wwv_flow_api.g_varchar2_table(3) := '2C723D7B7D2C613D7B7D3B66756E6374696F6E206328652C742C6E2C73297B76617220693D242E657874656E64287B7D2C7B6469736D6973733A5B226F6E436C69636B222C226F6E427574746F6E225D2C6469736D69737341667465723A6E756C6C2C6E';
wwv_flow_api.g_varchar2_table(4) := '65776573744F6E546F703A21302C70726576656E744475706C6963617465733A21312C65736361706548746D6C3A21302C706F736974696F6E3A22746F702D7269676874222C69636F6E436C6173733A6E756C6C2C636C656172416C6C3A21317D2C7329';
wwv_flow_api.g_varchar2_table(5) := '3B72657475726E226F626A656374223D3D747970656F6620743F28742E747970653D652C7028242E657874656E6428692C7B747970653A657D2C742929293A747C7C6E3F28216E2626742626286E3D742C743D766F69642030292C7028242E657874656E';
wwv_flow_api.g_varchar2_table(6) := '64287B7D2C7B747970653A652C6D6573736167653A742C7469746C653A6E7D2C692929293A766F696420617065782E64656275672E696E666F2822666F7374723A206E6F207469746C65206F72206D657373616765207761732070726F76696465642E20';
wwv_flow_api.g_varchar2_table(7) := '6E6F742073686F77696E67206E6F74696669636174696F6E2E22297D66756E6374696F6E206C28297B2428222E666F7374722D636F6E7461696E657222292E6368696C6472656E28292E72656D6F766528297D66756E6374696F6E20702874297B766172';
wwv_flow_api.g_varchar2_table(8) := '206E2C732C693D286E3D742E706F736974696F6E2C725B6E5D7C7C66756E6374696F6E2874297B766172206E3D2428223C6469762F3E22292E616464436C6173732822666F7374722D222B74292E616464436C6173732865293B72657475726E20242822';
wwv_flow_api.g_varchar2_table(9) := '626F647922292E617070656E64286E292C725B745D3D6E2C6E7D286E29292C633D742E6469736D6973732E696E636C7564657328226F6E436C69636B22292C703D742E6469736D6973732E696E636C7564657328226F6E427574746F6E22292C643D2428';
wwv_flow_api.g_varchar2_table(10) := '273C64697620636C6173733D22666F732D416C65727420666F732D416C6572742D2D686F72697A6F6E74616C20666F732D416C6572742D2D7061676520272B7B737563636573733A22666F732D416C6572742D2D73756363657373222C6572726F723A22';
wwv_flow_api.g_varchar2_table(11) := '666F732D416C6572742D2D64616E676572222C7761726E696E673A22666F732D416C6572742D2D7761726E696E67222C696E666F3A22666F732D416C6572742D2D696E666F227D5B742E747970655D2B272220726F6C653D22616C657274223E3C2F6469';
wwv_flow_api.g_varchar2_table(12) := '763E27292C663D2428273C64697620636C6173733D22666F732D416C6572742D77726170223E27292C753D2428273C64697620636C6173733D22666F732D416C6572742D69636F6E223E3C2F6469763E27292C763D2428273C7370616E20636C6173733D';
wwv_flow_api.g_varchar2_table(13) := '22742D49636F6E20666120272B28742E69636F6E436C6173737C7C6F5B742E747970655D292B27223E3C2F7370616E3E27292C6D3D2428273C64697620636C6173733D22666F732D416C6572742D636F6E74656E74223E3C2F6469763E27292C673D2428';
wwv_flow_api.g_varchar2_table(14) := '273C683220636C6173733D22666F732D416C6572742D7469746C65223E3C2F68323E27292C413D2428273C64697620636C6173733D22666F732D416C6572742D626F6479223E3C2F6469763E27292C773D2428273C64697620636C6173733D22666F732D';
wwv_flow_api.g_varchar2_table(15) := '416C6572742D627574746F6E73223E3C2F6469763E27293B70262628733D2428273C627574746F6E20636C6173733D22742D427574746F6E20742D427574746F6E2D2D6E6F554920742D427574746F6E2D2D69636F6E20742D427574746F6E2D2D636C6F';
wwv_flow_api.g_varchar2_table(16) := '7365416C6572742220747970653D22627574746F6E22207469746C653D22436C6F7365204E6F74696669636174696F6E223E3C7370616E20636C6173733D22742D49636F6E2069636F6E2D636C6F7365223E3C2F7370616E3E3C2F627574746F6E3E2729';
wwv_flow_api.g_varchar2_table(17) := '292C642E617070656E642866292C662E617070656E642875292C752E617070656E642876292C662E617070656E64286D292C6D2E617070656E642867292C6D2E617070656E642841292C662E617070656E642877292C702626772E617070656E64287329';
wwv_flow_api.g_varchar2_table(18) := '3B76617220683D742E7469746C653B68262628742E65736361706548746D6C262628683D617065782E7574696C2E65736361706548544D4C286829292C672E617070656E64286829293B76617220793D742E6D6573736167653B69662879262628742E65';
wwv_flow_api.g_varchar2_table(19) := '736361706548746D6C262622737472696E67223D3D747970656F662079262628793D617065782E7574696C2E65736361706548544D4C287929292C412E617070656E64287929292C2128742E70726576656E744475706C6963617465732626612626612E';
wwv_flow_api.g_varchar2_table(20) := '24656C656D2626612E24656C656D2E697328223A76697369626C6522292626612E7469746C653D3D682626612E6D6573736167653D3D7929297B766172206B3B73776974636828613D7B24656C656D3A642C7469746C653A682C6D6573736167653A797D';
wwv_flow_api.g_varchar2_table(21) := '2C742E636C656172416C6C26266C28292C742E6E65776573744F6E546F703F692E70726570656E642864293A692E617070656E642864292C742E74797065297B636173652273756363657373223A6361736522696E666F223A6B3D22706F6C697465223B';
wwv_flow_api.g_varchar2_table(22) := '627265616B3B64656661756C743A6B3D22617373657274697665227D642E617474722822617269612D6C697665222C6B293B76617220623D2428223C6469762F3E22293B696628742E6469736D69737341667465723E30297B622E616464436C61737328';
wwv_flow_api.g_varchar2_table(23) := '22666F7374722D70726F677265737322292C642E617070656E642862293B76617220543D73657454696D656F7574282866756E6374696F6E28297B642E72656D6F766528297D292C742E6469736D6973734166746572293B622E637373287B7769647468';
wwv_flow_api.g_varchar2_table(24) := '3A2231303025222C7472616E736974696F6E3A22776964746820222B28742E6469736D69737341667465722D313030292F3165332B2273206C696E656172227D292C73657454696D656F7574282866756E6374696F6E28297B622E637373282277696474';
wwv_flow_api.g_varchar2_table(25) := '68222C223022297D292C313030292C642E6F6E28226D6F7573656F76657220636C69636B222C2866756E6374696F6E28297B636C65617254696D656F75742854292C622E72656D6F766528297D29297D72657475726E20632626642E6F6E2822636C6963';
wwv_flow_api.g_varchar2_table(26) := '6B222C2866756E6374696F6E2865297B696628215B2241222C22425554544F4E225D2E696E636C75646573282428652E746172676574292E70726F7028226E6F64654E616D65222929297B76617220743D77696E646F772E67657453656C656374696F6E';
wwv_flow_api.g_varchar2_table(27) := '28293B7426262252616E6765223D3D742E747970652626742E616E63686F724E6F646526262428742E616E63686F724E6F64652C64292E6C656E6774683E307C7C642E72656D6F766528297D7D29292C702626732E6F6E2822636C69636B222C2866756E';
wwv_flow_api.g_varchar2_table(28) := '6374696F6E28297B642E72656D6F766528297D29292C2266756E6374696F6E223D3D747970656F6620742E6F6E636C69636B262628642E6F6E2822636C69636B222C742E6F6E636C69636B292C702626732E6F6E2822636C69636B222C742E6F6E636C69';
wwv_flow_api.g_varchar2_table(29) := '636B29292C647D7D72657475726E7B737563636573733A66756E6374696F6E28652C6E2C73297B72657475726E206328742C652C6E2C73297D2C696E666F3A66756E6374696F6E28652C742C73297B72657475726E2063286E2C652C742C73297D2C7761';
wwv_flow_api.g_varchar2_table(30) := '726E696E673A66756E6374696F6E28652C742C6E297B72657475726E206328732C652C742C6E297D2C6572726F723A66756E6374696F6E28652C742C6E297B72657475726E206328692C652C742C6E297D2C636C656172416C6C3A6C2C76657273696F6E';
wwv_flow_api.g_varchar2_table(31) := '3A2232302E322E30227D7D28293B0A2F2F2320736F757263654D617070696E6755524C3D666F7374722E6A732E6D6170';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(44085614526172054)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_file_name=>'js/fostr.min.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D64616E67657220612C2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E6720617B636F6C6F723A696E68657269743B746578742D6465636F7261';
wwv_flow_api.g_varchar2_table(2) := '74696F6E3A756E6465726C696E657D2E666F732D416C6572742D2D686F72697A6F6E74616C7B626F726465722D7261646975733A3270783B6261636B67726F756E642D636F6C6F723A236666663B636F6C6F723A233236323632363B6D617267696E2D62';
wwv_flow_api.g_varchar2_table(3) := '6F74746F6D3A312E3672656D3B706F736974696F6E3A72656C61746976653B626F726465723A31707820736F6C6964207267626128302C302C302C2E31293B626F782D736861646F773A302032707820347078202D327078207267626128302C302C302C';
wwv_flow_api.g_varchar2_table(4) := '2E303735297D2E666F732D416C6572742D69636F6E202E742D49636F6E7B636F6C6F723A236666667D2E666F732D416C6572742D2D7761726E696E67202E666F732D416C6572742D69636F6E202E742D49636F6E7B636F6C6F723A236662636634617D2E';
wwv_flow_api.g_varchar2_table(5) := '666F732D416C6572742D2D7761726E696E672E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E7B6261636B67726F756E642D636F6C6F723A72676261283235312C3230372C37342C2E3135297D2E666F732D';
wwv_flow_api.g_varchar2_table(6) := '416C6572742D2D73756363657373202E666F732D416C6572742D69636F6E202E742D49636F6E7B636F6C6F723A233362616132637D2E666F732D416C6572742D2D737563636573732E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D';
wwv_flow_api.g_varchar2_table(7) := '416C6572742D69636F6E7B6261636B67726F756E642D636F6C6F723A726762612835392C3137302C34342C2E3135297D2E666F732D416C6572742D2D696E666F202E666F732D416C6572742D69636F6E202E742D49636F6E7B636F6C6F723A2330303736';
wwv_flow_api.g_varchar2_table(8) := '64667D2E666F732D416C6572742D2D696E666F2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E7B6261636B67726F756E642D636F6C6F723A7267626128302C3131382C3232332C2E3135297D2E666F732D';
wwv_flow_api.g_varchar2_table(9) := '416C6572742D2D64616E676572202E666F732D416C6572742D69636F6E202E742D49636F6E7B636F6C6F723A236634343333367D2E666F732D416C6572742D2D64616E6765722E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C';
wwv_flow_api.g_varchar2_table(10) := '6572742D69636F6E7B6261636B67726F756E642D636F6C6F723A72676261283234342C36372C35342C2E3135297D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D737563636573737B6261636B67726F756E642D636F6C6F723A72';
wwv_flow_api.g_varchar2_table(11) := '6762612835392C3137302C34342C2E39293B636F6C6F723A236666667D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D73756363657373202E666F732D416C6572742D69636F6E7B6261636B67726F756E642D636F6C6F723A7472';
wwv_flow_api.g_varchar2_table(12) := '616E73706172656E743B636F6C6F723A236666667D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D64616E676572202E666F732D416C6572742D69636F6E202E742D49636F6E2C2E666F732D416C6572742D2D706167652E666F73';
wwv_flow_api.g_varchar2_table(13) := '2D416C6572742D2D696E666F202E666F732D416C6572742D69636F6E202E742D49636F6E2C2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D73756363657373202E666F732D416C6572742D69636F6E202E742D49636F6E2C2E666F';
wwv_flow_api.g_varchar2_table(14) := '732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E666F732D416C6572742D69636F6E202E742D49636F6E7B636F6C6F723A696E68657269747D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D73';
wwv_flow_api.g_varchar2_table(15) := '756363657373202E742D427574746F6E2D2D636C6F7365416C6572747B636F6C6F723A2366666621696D706F7274616E747D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E677B6261636B67726F756E642D636F6C';
wwv_flow_api.g_varchar2_table(16) := '6F723A236662636634613B636F6C6F723A233434333430327D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E666F732D416C6572742D69636F6E7B6261636B67726F756E642D636F6C6F723A7472616E7370';
wwv_flow_api.g_varchar2_table(17) := '6172656E743B636F6C6F723A233434333430327D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E742D427574746F6E2D2D636C6F7365416C6572747B636F6C6F723A2366666621696D706F7274616E747D2E';
wwv_flow_api.g_varchar2_table(18) := '666F732D416C6572742D2D706167652E666F732D416C6572742D2D696E666F7B6261636B67726F756E642D636F6C6F723A233030373664663B636F6C6F723A236666667D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D696E666F';
wwv_flow_api.g_varchar2_table(19) := '202E666F732D416C6572742D69636F6E7B6261636B67726F756E642D636F6C6F723A7472616E73706172656E743B636F6C6F723A236666667D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D696E666F202E742D427574746F6E2D';
wwv_flow_api.g_varchar2_table(20) := '2D636C6F7365416C6572747B636F6C6F723A2366666621696D706F7274616E747D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D64616E6765727B6261636B67726F756E642D636F6C6F723A236634343333363B636F6C6F723A23';
wwv_flow_api.g_varchar2_table(21) := '6666667D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D64616E676572202E666F732D416C6572742D69636F6E7B6261636B67726F756E642D636F6C6F723A7472616E73706172656E743B636F6C6F723A236666667D2E666F732D';
wwv_flow_api.g_varchar2_table(22) := '416C6572742D2D706167652E666F732D416C6572742D2D64616E676572202E742D427574746F6E2D2D636C6F7365416C6572747B636F6C6F723A2366666621696D706F7274616E747D2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F73';
wwv_flow_api.g_varchar2_table(23) := '2D416C6572742D777261707B646973706C61793A666C65783B666C65782D646972656374696F6E3A726F777D2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E7B70616464696E673A3020313670783B666C';
wwv_flow_api.g_varchar2_table(24) := '65782D736872696E6B3A303B646973706C61793A666C65783B616C69676E2D6974656D733A63656E7465727D2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D636F6E74656E747B70616464696E673A313670783B66';
wwv_flow_api.g_varchar2_table(25) := '6C65783A3120303B646973706C61793A666C65783B666C65782D646972656374696F6E3A636F6C756D6E3B6A7573746966792D636F6E74656E743A63656E7465727D2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D';
wwv_flow_api.g_varchar2_table(26) := '627574746F6E737B666C65782D736872696E6B3A303B746578742D616C69676E3A72696768743B77686974652D73706163653A6E6F777261703B70616464696E672D72696768743A312E3672656D3B646973706C61793A666C65783B616C69676E2D6974';
wwv_flow_api.g_varchar2_table(27) := '656D733A63656E7465727D2E752D52544C202E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D627574746F6E737B70616464696E672D72696768743A303B70616464696E672D6C6566743A312E3672656D7D2E666F73';
wwv_flow_api.g_varchar2_table(28) := '2D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D626F64793A656D7074792C2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D627574746F6E733A656D7074797B646973706C61793A6E6F6E';
wwv_flow_api.g_varchar2_table(29) := '657D2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D7469746C657B666F6E742D73697A653A3272656D3B6C696E652D6865696768743A322E3472656D3B6D617267696E2D626F74746F6D3A307D2E666F732D416C65';

wwv_flow_api.g_varchar2_table(30) := '72742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E202E742D49636F6E7B666F6E742D73697A653A333270783B77696474683A333270783B746578742D616C69676E3A63656E7465723B6865696768743A333270783B6C696E652D';
wwv_flow_api.g_varchar2_table(31) := '6865696768743A317D2E666F732D416C6572742D2D6E6F49636F6E2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E7B646973706C61793A6E6F6E6521696D706F7274616E747D2E666F732D416C6572742D';
wwv_flow_api.g_varchar2_table(32) := '2D6E6F49636F6E202E666F732D416C6572742D69636F6E202E742D49636F6E7B646973706C61793A6E6F6E657D2E742D426F64792D616C6572747B6D617267696E3A307D2E742D426F64792D616C657274202E666F732D416C6572747B6D617267696E2D';
wwv_flow_api.g_varchar2_table(33) := '626F74746F6D3A307D2E666F732D416C6572742D2D706167657B7472616E736974696F6E3A2E327320656173652D6F75743B6D61782D77696474683A36343070783B6D696E2D77696474683A33323070783B7A2D696E6465783A313030303B626F726465';
wwv_flow_api.g_varchar2_table(34) := '722D77696474683A303B626F782D736861646F773A3020302030202E3172656D207267626128302C302C302C2E312920696E7365742C302033707820397078202D327078207267626128302C302C302C2E31297D2E666F732D416C6572742D2D70616765';
wwv_flow_api.g_varchar2_table(35) := '202E666F732D416C6572742D627574746F6E737B70616464696E672D72696768743A307D2E666F732D416C6572742D2D70616765202E666F732D416C6572742D69636F6E7B70616464696E672D6C6566743A312E3672656D3B70616464696E672D726967';
wwv_flow_api.g_varchar2_table(36) := '68743A3870787D2E752D52544C202E666F732D416C6572742D2D70616765202E666F732D416C6572742D69636F6E7B70616464696E672D6C6566743A3870783B70616464696E672D72696768743A312E3672656D7D2E666F732D416C6572742D2D706167';
wwv_flow_api.g_varchar2_table(37) := '65202E666F732D416C6572742D69636F6E202E742D49636F6E7B666F6E742D73697A653A323470783B77696474683A323470783B6865696768743A323470783B6C696E652D6865696768743A317D2E666F732D416C6572742D2D70616765202E666F732D';
wwv_flow_api.g_varchar2_table(38) := '416C6572742D626F64797B70616464696E672D626F74746F6D3A3870787D2E666F732D416C6572742D2D70616765202E666F732D416C6572742D636F6E74656E747B70616464696E673A3870787D2E666F732D416C6572742D2D70616765202E742D4275';
wwv_flow_api.g_varchar2_table(39) := '74746F6E2D2D636C6F7365416C6572747B706F736974696F6E3A6162736F6C7574653B72696768743A2D3870783B746F703A2D3870783B70616464696E673A3470783B6D696E2D77696474683A303B6261636B67726F756E642D636F6C6F723A23303030';
wwv_flow_api.g_varchar2_table(40) := '21696D706F7274616E743B636F6C6F723A2366666621696D706F7274616E743B626F782D736861646F773A3020302030203170782072676261283235352C3235352C3235352C2E32352921696D706F7274616E743B626F726465722D7261646975733A32';
wwv_flow_api.g_varchar2_table(41) := '3470783B7472616E736974696F6E3A7472616E73666F726D202E3132357320656173653B7472616E736974696F6E3A7472616E73666F726D202E3132357320656173652C2D7765626B69742D7472616E73666F726D202E3132357320656173657D2E752D';
wwv_flow_api.g_varchar2_table(42) := '52544C202E666F732D416C6572742D2D70616765202E742D427574746F6E2D2D636C6F7365416C6572747B72696768743A6175746F3B6C6566743A2D3870787D2E666F732D416C6572742D2D70616765202E742D427574746F6E2D2D636C6F7365416C65';
wwv_flow_api.g_varchar2_table(43) := '72743A686F7665727B2D7765626B69742D7472616E73666F726D3A7363616C6528312E3135293B7472616E73666F726D3A7363616C6528312E3135297D2E666F732D416C6572742D2D70616765202E742D427574746F6E2D2D636C6F7365416C6572743A';
wwv_flow_api.g_varchar2_table(44) := '6163746976657B2D7765626B69742D7472616E73666F726D3A7363616C65282E3835293B7472616E73666F726D3A7363616C65282E3835297D2E666F732D416C6572742D2D706167652E666F732D416C6572747B626F726465722D7261646975733A2E34';
wwv_flow_api.g_varchar2_table(45) := '72656D7D2E666F732D416C6572742D2D70616765202E666F732D416C6572742D7469746C657B70616464696E673A38707820307D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E612D4E6F74696669636174';
wwv_flow_api.g_varchar2_table(46) := '696F6E7B6D617267696E2D72696768743A3870787D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E612D4E6F74696669636174696F6E2D7469746C657B666F6E742D73697A653A312E3472656D3B6C696E65';
wwv_flow_api.g_varchar2_table(47) := '2D6865696768743A3272656D3B666F6E742D7765696768743A3730303B6D617267696E3A307D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E612D4E6F74696669636174696F6E2D6C6973747B6D61782D68';
wwv_flow_api.g_varchar2_table(48) := '65696768743A31323870787D2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6C6973747B6D61782D6865696768743A393670783B6F766572666C6F773A6175746F7D2E666F732D416C6572742D2D70616765202E612D';
wwv_flow_api.g_varchar2_table(49) := '4E6F74696669636174696F6E2D6C696E6B3A686F7665727B746578742D6465636F726174696F6E3A756E6465726C696E657D2E666F732D416C6572742D2D70616765203A3A2D7765626B69742D7363726F6C6C6261727B77696474683A3870783B686569';
wwv_flow_api.g_varchar2_table(50) := '6768743A3870787D2E666F732D416C6572742D2D70616765203A3A2D7765626B69742D7363726F6C6C6261722D7468756D627B6261636B67726F756E642D636F6C6F723A7267626128302C302C302C2E3235297D2E666F732D416C6572742D2D70616765';
wwv_flow_api.g_varchar2_table(51) := '203A3A2D7765626B69742D7363726F6C6C6261722D747261636B7B6261636B67726F756E642D636F6C6F723A7267626128302C302C302C2E3035297D2E666F732D416C6572742D2D70616765202E666F732D416C6572742D7469746C657B646973706C61';
wwv_flow_api.g_varchar2_table(52) := '793A626C6F636B3B666F6E742D7765696768743A3730303B666F6E742D73697A653A312E3872656D3B6D617267696E2D626F74746F6D3A303B6D617267696E2D72696768743A313670787D2E666F732D416C6572742D2D70616765202E666F732D416C65';
wwv_flow_api.g_varchar2_table(53) := '72742D626F64797B6D617267696E2D72696768743A313670787D2E752D52544C202E666F732D416C6572742D2D70616765202E666F732D416C6572742D626F64792C2E752D52544C202E666F732D416C6572742D2D70616765202E666F732D416C657274';
wwv_flow_api.g_varchar2_table(54) := '2D7469746C657B6D617267696E2D72696768743A303B6D617267696E2D6C6566743A313670787D2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6C6973747B6D617267696E3A347078203020303B70616464696E673A';
wwv_flow_api.g_varchar2_table(55) := '303B6C6973742D7374796C653A6E6F6E657D2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D7B70616464696E672D6C6566743A323070783B706F736974696F6E3A72656C61746976653B666F6E742D73697A';
wwv_flow_api.g_varchar2_table(56) := '653A313470783B6C696E652D6865696768743A323070783B6D617267696E2D626F74746F6D3A3470787D2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D3A6C6173742D6368696C647B6D617267696E2D626F';
wwv_flow_api.g_varchar2_table(57) := '74746F6D3A307D2E752D52544C202E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D7B70616464696E672D6C6566743A303B70616464696E672D72696768743A323070787D2E666F732D416C6572742D2D7061';
wwv_flow_api.g_varchar2_table(58) := '6765202E612D4E6F74696669636174696F6E2D6974656D3A6265666F72657B636F6E74656E743A27273B706F736974696F6E3A6162736F6C7574653B6D617267696E3A3870783B746F703A303B6C6566743A303B77696474683A3470783B686569676874';
wwv_flow_api.g_varchar2_table(59) := '3A3470783B626F726465722D7261646975733A313030253B6261636B67726F756E642D636F6C6F723A7267626128302C302C302C2E35297D2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D202E612D427574';
wwv_flow_api.g_varchar2_table(60) := '746F6E2D2D6E6F74696669636174696F6E7B70616464696E673A3270783B6F7061636974793A2E37353B766572746963616C2D616C69676E3A746F707D2E666F732D416C6572742D2D70616765202E68746D6C64624F72614572727B6D617267696E2D74';
wwv_flow_api.g_varchar2_table(61) := '6F703A2E3872656D3B646973706C61793A626C6F636B3B666F6E742D73697A653A312E3172656D3B6C696E652D6865696768743A312E3672656D3B666F6E742D66616D696C793A274D656E6C6F272C27436F6E736F6C6173272C6D6F6E6F73706163652C';
wwv_flow_api.g_varchar2_table(62) := '73657269663B77686974652D73706163653A7072652D6C696E657D2E666F732D416C6572742D2D61636365737369626C6548656164696E67202E666F732D416C6572742D7469746C657B626F726465723A303B636C69703A726563742830203020302030';
wwv_flow_api.g_varchar2_table(63) := '293B6865696768743A3170783B6D617267696E3A2D3170783B6F766572666C6F773A68696464656E3B70616464696E673A303B706F736974696F6E3A6162736F6C7574653B77696474683A3170787D2E666F732D416C6572742D2D72656D6F7665486561';
wwv_flow_api.g_varchar2_table(64) := '64696E67202E666F732D416C6572742D7469746C657B646973706C61793A6E6F6E657D406D6564696120286D61782D77696474683A3438307078297B2E666F732D416C6572742D2D706167657B6D696E2D77696474683A303B6D61782D77696474683A6E';
wwv_flow_api.g_varchar2_table(65) := '6F6E657D2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D7B666F6E742D73697A653A313270787D7D406D6564696120286D61782D77696474683A3736387078297B2E666F732D416C6572742D2D686F72697A';
wwv_flow_api.g_varchar2_table(66) := '6F6E74616C202E666F732D416C6572742D7469746C657B666F6E742D73697A653A312E3872656D7D7D2E666F732D416C657274202E742D49636F6E2E69636F6E2D636C6F73653A6265666F72657B666F6E742D66616D696C793A22617065782D352D6963';
wwv_flow_api.g_varchar2_table(67) := '6F6E2D666F6E74223B646973706C61793A696E6C696E652D626C6F636B3B766572746963616C2D616C69676E3A746F703B6C696E652D6865696768743A313670783B666F6E742D73697A653A313670783B636F6E74656E743A225C65306132227D2E666F';
wwv_flow_api.g_varchar2_table(68) := '7374722D746F702D63656E7465727B746F703A312E3672656D3B72696768743A303B77696474683A313030257D2E666F7374722D626F74746F6D2D63656E7465727B626F74746F6D3A312E3672656D3B72696768743A303B77696474683A313030257D2E';
wwv_flow_api.g_varchar2_table(69) := '666F7374722D746F702D72696768747B746F703A312E3672656D3B72696768743A312E3672656D7D2E666F7374722D746F702D6C6566747B746F703A312E3672656D3B6C6566743A312E3672656D7D2E666F7374722D626F74746F6D2D72696768747B72';
wwv_flow_api.g_varchar2_table(70) := '696768743A312E3672656D3B626F74746F6D3A312E3672656D7D2E666F7374722D626F74746F6D2D6C6566747B626F74746F6D3A312E3672656D3B6C6566743A312E3672656D7D2E666F7374722D636F6E7461696E65727B706F736974696F6E3A666978';
wwv_flow_api.g_varchar2_table(71) := '65643B7A2D696E6465783A3939393939393B706F696E7465722D6576656E74733A6E6F6E657D2E666F7374722D636F6E7461696E65723E6469767B706F696E7465722D6576656E74733A6175746F7D2E666F7374722D636F6E7461696E65722E666F7374';
wwv_flow_api.g_varchar2_table(72) := '722D626F74746F6D2D63656E7465723E6469762C2E666F7374722D636F6E7461696E65722E666F7374722D746F702D63656E7465723E6469767B6D617267696E2D6C6566743A6175746F3B6D617267696E2D72696768743A6175746F7D2E666F7374722D';
wwv_flow_api.g_varchar2_table(73) := '70726F67726573737B706F736974696F6E3A6162736F6C7574653B626F74746F6D3A303B6865696768743A3470783B6261636B67726F756E642D636F6C6F723A233030303B6F7061636974793A2E347D68746D6C3A6E6F74282E752D52544C29202E666F';
wwv_flow_api.g_varchar2_table(74) := '7374722D70726F67726573737B6C6566743A303B626F726465722D626F74746F6D2D6C6566742D7261646975733A2E3472656D7D68746D6C2E752D52544C202E666F7374722D70726F67726573737B72696768743A303B626F726465722D626F74746F6D';
wwv_flow_api.g_varchar2_table(75) := '2D72696768742D7261646975733A2E3472656D7D406D6564696120286D61782D77696474683A3438307078297B2E666F7374722D636F6E7461696E65727B6C6566743A312E3672656D3B72696768743A312E3672656D7D7D0A2F2A2320736F757263654D';
wwv_flow_api.g_varchar2_table(76) := '617070696E6755524C3D666F7374722E6373732E6D61702A2F';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(44086091064173702)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_file_name=>'css/fostr.min.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A0A202A2052544C20737570706F72742073686F756C6420626520646F6E6520696E20637373206F6E6C792E20636C61737320752D52544C20657869737473206F6E2074686520626F6479207768656E206170657820697320696E2052544C206D6F64';
wwv_flow_api.g_varchar2_table(2) := '652E0A202A204E6F7465207468617420746869732073686F756C64206F6E6C792061666665637420656C656D656E74732077697468696E20746865206E6F74696669636174696F6E2C206E6F742074686520706F736974696F6E696E67206F6620746865';
wwv_flow_api.g_varchar2_table(3) := '2061637475616C206E6F74696669636174696F6E2E0A202A20546869732069732074616B656E2063617265206F66206279206120706C75672D696E2073657474696E67732E0A202A0A202A2F0A0A2F2A0A202A20466F7374720A202A20436F7079726967';
wwv_flow_api.g_varchar2_table(4) := '687420323032300A202A20417574686F72733A2053746566616E20446F6272650A202A200A202A204372656469747320666F722074686520626173652076657273696F6E20676F20746F3A2068747470733A2F2F6769746875622E636F6D2F436F646553';
wwv_flow_api.g_varchar2_table(5) := '6576656E2F746F617374720A202A204F726967696E616C20417574686F72733A204A6F686E20506170612C2048616E7320466AC3A46C6C656D61726B2C20616E642054696D2046657272656C6C2E0A202A204152494120537570706F72743A2047726574';
wwv_flow_api.g_varchar2_table(6) := '61204B7261667369670A202A200A202A20416C6C205269676874732052657365727665642E0A202A205573652C20726570726F64756374696F6E2C20646973747269627574696F6E2C20616E64206D6F64696669636174696F6E206F6620746869732063';
wwv_flow_api.g_varchar2_table(7) := '6F6465206973207375626A65637420746F20746865207465726D7320616E640A202A20636F6E646974696F6E73206F6620746865204D4954206C6963656E73652C20617661696C61626C6520617420687474703A2F2F7777772E6F70656E736F75726365';
wwv_flow_api.g_varchar2_table(8) := '2E6F72672F6C6963656E7365732F6D69742D6C6963656E73652E7068700A202A0A202A2050726F6A6563743A2068747470733A2F2F6769746875622E636F6D2F666F65782D6F70656E2D736F757263652F666F7374720A202A2F0A77696E646F772E666F';
wwv_flow_api.g_varchar2_table(9) := '737472203D202866756E6374696F6E2829207B0A0A2020202076617220434F4E5441494E45525F434C415353203D2027666F7374722D636F6E7461696E6572273B0A0A2020202076617220746F61737454797065203D207B0A2020202020202020737563';
wwv_flow_api.g_varchar2_table(10) := '636573733A202773756363657373272C0A2020202020202020696E666F3A2027696E666F272C0A20202020202020207761726E696E673A20277761726E696E67272C0A20202020202020206572726F723A20276572726F72270A202020207D3B0A0A2020';
wwv_flow_api.g_varchar2_table(11) := '20207661722069636F6E436C6173736573203D207B0A2020202020202020737563636573733A202766612D636865636B2D636972636C65272C0A2020202020202020696E666F3A202766612D696E666F2D636972636C65272C0A20202020202020207761';
wwv_flow_api.g_varchar2_table(12) := '726E696E673A202766612D6578636C616D6174696F6E2D747269616E676C65272C0A20202020202020206572726F723A202766612D74696D65732D636972636C65270A202020207D3B0A0A2020202076617220636F6E7461696E657273203D207B7D3B0A';
wwv_flow_api.g_varchar2_table(13) := '202020207661722070726576696F7573546F617374203D207B7D3B0A0A2020202066756E6374696F6E206E6F746966795479706528747970652C206D6573736167652C207469746C652C206F7074696F6E7329207B0A0A20202020202020207661722066';
wwv_flow_api.g_varchar2_table(14) := '696E616C4F7074696F6E73203D20242E657874656E64287B7D2C207B0A2020202020202020202020206469736D6973733A205B276F6E436C69636B272C20276F6E427574746F6E275D2C2020202F2F207768656E20746F206469736D6973732074686520';
wwv_flow_api.g_varchar2_table(15) := '6E6F74696669636174696F6E0A2020202020202020202020206469736D69737341667465723A206E756C6C2C20202020202020202020202020202020202F2F2061206E756D62657220696E206D696C6C697365636F6E6473206166746572207768696368';
wwv_flow_api.g_varchar2_table(16) := '20746865206E6F74696669636174696F6E2073686F756C64206265206175746F6D61746963616C6C792072656D6F7665642E20686F766572696E67206F7220636C69636B696E6720746865206E6F74696669636174696F6E2073746F7073207468697320';
wwv_flow_api.g_varchar2_table(17) := '6576656E740A2020202020202020202020206E65776573744F6E546F703A20747275652C2020202020202020202020202020202020202F2F2061646420746F2074686520746F70206F6620746865206C6973740A20202020202020202020202070726576';
wwv_flow_api.g_varchar2_table(18) := '656E744475706C6963617465733A2066616C73652C20202020202020202020202F2F20646F206E6F742073686F7720746865206E6F74696669636174696F6E20696620697420686173207468652073616D65207469746C6520616E64206D657373616765';
wwv_flow_api.g_varchar2_table(19) := '20617320746865206C617374206F6E6520616E6420696620746865206C617374206F6E65206973207374696C6C2076697369626C650A20202020202020202020202065736361706548746D6C3A20747275652C2020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(20) := '20202F2F207768657468657220746F2065736361706520746865207469746C6520616E64206D6573736167650A202020202020202020202020706F736974696F6E3A2027746F702D7269676874272C20202020202020202020202020202F2F206F6E6520';
wwv_flow_api.g_varchar2_table(21) := '6F6620363A205B746F707C626F74746F6D5D2D5B72696768747C63656E7465727C6C6566745D0A20202020202020202020202069636F6E436C6173733A206E756C6C2C20202020202020202020202020202020202020202F2F207768656E206C65667420';
wwv_flow_api.g_varchar2_table(22) := '746F206E756C6C2C2069742077696C6C2062652064656661756C74656420746F2074686520636F72726573706F6E64696E672069636F6E2066726F6D2069636F6E436C61737365730A202020202020202020202020636C656172416C6C3A2066616C7365';
wwv_flow_api.g_varchar2_table(23) := '2020202020202020202020202020202020202020202F2F207472756520746F20636C65617220616C6C206E6F74696669636174696F6E732066697273740A20202020202020207D2C206F7074696F6E73293B0A0A20202020202020202F2F206966207468';
wwv_flow_api.g_varchar2_table(24) := '65206D6573736167652061747472696275746520697320616E206F626A6563740A202020202020202069662028747970656F66206D657373616765203D3D3D20276F626A6563742729207B0A2020202020202020202020206D6573736167652E74797065';
wwv_flow_api.g_varchar2_table(25) := '203D20747970653B0A20202020202020202020202072657475726E206E6F7469667928242E657874656E642866696E616C4F7074696F6E732C207B0A20202020202020202020202020202020747970653A20747970650A2020202020202020202020207D';
wwv_flow_api.g_varchar2_table(26) := '2C206D65737361676529293B0A20202020202020207D20656C736520696620286D657373616765207C7C207469746C6529207B0A20202020202020202020202069662028217469746C65202626206D65737361676529207B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(27) := '20202020207469746C65203D206D6573736167653B0A202020202020202020202020202020206D657373616765203D20756E646566696E65643B0A2020202020202020202020207D0A20202020202020202020202072657475726E206E6F746966792824';
wwv_flow_api.g_varchar2_table(28) := '2E657874656E64287B7D2C7B0A20202020202020202020202020202020747970653A20747970652C0A202020202020202020202020202020206D6573736167653A206D6573736167652C0A202020202020202020202020202020207469746C653A207469';
wwv_flow_api.g_varchar2_table(29) := '746C650A2020202020202020202020207D2C2066696E616C4F7074696F6E7329293B0A20202020202020207D20656C7365207B0A202020202020202020202020617065782E64656275672E696E666F2827666F7374723A206E6F207469746C65206F7220';
wwv_flow_api.g_varchar2_table(30) := '6D657373616765207761732070726F76696465642E206E6F742073686F77696E67206E6F74696669636174696F6E2E27293B0A20202020202020207D0A202020207D0A0A2020202066756E6374696F6E2073756363657373286D6573736167652C207469';
wwv_flow_api.g_varchar2_table(31) := '746C652C206F7074696F6E7329207B0A202020202020202072657475726E206E6F746966795479706528746F617374547970652E737563636573732C206D6573736167652C207469746C652C206F7074696F6E73293B0A202020207D0A0A202020206675';
wwv_flow_api.g_varchar2_table(32) := '6E6374696F6E207761726E696E67286D6573736167652C207469746C652C206F7074696F6E7329207B0A202020202020202072657475726E206E6F746966795479706528746F617374547970652E7761726E696E672C206D6573736167652C207469746C';
wwv_flow_api.g_varchar2_table(33) := '652C206F7074696F6E73293B0A202020207D0A0A2020202066756E6374696F6E20696E666F286D6573736167652C207469746C652C206F7074696F6E7329207B0A202020202020202072657475726E206E6F746966795479706528746F61737454797065';
wwv_flow_api.g_varchar2_table(34) := '2E696E666F2C206D6573736167652C207469746C652C206F7074696F6E73293B0A202020207D0A0A2020202066756E6374696F6E206572726F72286D6573736167652C207469746C652C206F7074696F6E7329207B0A202020202020202072657475726E';
wwv_flow_api.g_varchar2_table(35) := '206E6F746966795479706528746F617374547970652E6572726F722C206D6573736167652C207469746C652C206F7074696F6E73293B0A202020207D0A0A2020202066756E6374696F6E20636C656172416C6C2829207B0A20202020202020202428272E';
wwv_flow_api.g_varchar2_table(36) := '27202B20434F4E5441494E45525F434C415353292E6368696C6472656E28292E72656D6F766528293B0A202020207D0A0A202020202F2F20696E7465726E616C2066756E6374696F6E730A0A2020202066756E6374696F6E20676574436F6E7461696E65';
wwv_flow_api.g_varchar2_table(37) := '7228706F736974696F6E29207B0A0A202020202020202066756E6374696F6E20637265617465436F6E7461696E657228706F736974696F6E29207B0A2020202020202020202020207661722024636F6E7461696E6572203D202428273C6469762F3E2729';
wwv_flow_api.g_varchar2_table(38) := '2E616464436C6173732827666F7374722D27202B20706F736974696F6E292E616464436C61737328434F4E5441494E45525F434C415353293B0A202020202020202020202020242827626F647927292E617070656E642824636F6E7461696E6572293B0A';
wwv_flow_api.g_varchar2_table(39) := '202020202020202020202020636F6E7461696E6572735B706F736974696F6E5D203D2024636F6E7461696E65723B0A20202020202020202020202072657475726E2024636F6E7461696E65723B0A20202020202020207D0A0A2020202020202020726574';
wwv_flow_api.g_varchar2_table(40) := '75726E20636F6E7461696E6572735B706F736974696F6E5D207C7C20637265617465436F6E7461696E657228706F736974696F6E293B0A202020207D0A0A2020202066756E6374696F6E206E6F7469667928636F6E66696729207B0A0A20202020202020';
wwv_flow_api.g_varchar2_table(41) := '207661722024636F6E7461696E6572203D20676574436F6E7461696E657228636F6E6669672E706F736974696F6E293B0A0A2020202020202020766172206469736D6973734F6E436C69636B203D20636F6E6669672E6469736D6973732E696E636C7564';
wwv_flow_api.g_varchar2_table(42) := '657328276F6E436C69636B27293B0A2020202020202020766172206469736D6973734F6E427574746F6E203D20636F6E6669672E6469736D6973732E696E636C7564657328276F6E427574746F6E27293B0A0A20202020202020202F2A0A202020202020';
wwv_flow_api.g_varchar2_table(43) := '20203C64697620636C6173733D22666F732D416C65727420666F732D416C6572742D2D686F72697A6F6E74616C20666F732D416C6572742D2D7061676520666F732D416C6572742D2D737563636573732220726F6C653D22616C657274223E0A20202020';
wwv_flow_api.g_varchar2_table(44) := '20202020202020203C64697620636C6173733D22666F732D416C6572742D77726170223E0A202020202020202020202020202020203C64697620636C6173733D22666F732D416C6572742D69636F6E223E0A202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(45) := '20203C7370616E20636C6173733D22742D49636F6E2066612066612D636865636B2D636972636C65223E3C2F7370616E3E0A202020202020202020202020202020203C2F6469763E0A202020202020202020202020202020203C64697620636C6173733D';
wwv_flow_api.g_varchar2_table(46) := '22666F732D416C6572742D636F6E74656E74223E0A20202020202020202020202020202020202020203C683220636C6173733D22666F732D416C6572742D7469746C65223E3C2F68323E0A20202020202020202020202020202020202020203C64697620';
wwv_flow_api.g_varchar2_table(47) := '636C6173733D22666F732D416C6572742D626F6479223E3C2F6469763E0A202020202020202020202020202020203C2F6469763E0A202020202020202020202020202020203C64697620636C6173733D22666F732D416C6572742D627574746F6E73223E';
wwv_flow_api.g_varchar2_table(48) := '0A20202020202020202020202020202020202020203C627574746F6E20636C6173733D22742D427574746F6E20742D427574746F6E2D2D6E6F554920742D427574746F6E2D2D69636F6E20742D427574746F6E2D2D636C6F7365416C6572742220747970';
wwv_flow_api.g_varchar2_table(49) := '653D22627574746F6E22207469746C653D22436C6F7365204E6F74696669636174696F6E223E3C7370616E20636C6173733D22742D49636F6E2069636F6E2D636C6F7365223E3C2F7370616E3E3C2F627574746F6E3E0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(50) := '2020203C2F6469763E0A2020202020202020202020203C2F6469763E0A20202020202020203C2F6469763E0A20202020202020202A2F0A0A20202020202020207661722074797065436C617373203D207B0A202020202020202020202020227375636365';
wwv_flow_api.g_varchar2_table(51) := '7373223A2022666F732D416C6572742D2D73756363657373222C0A202020202020202020202020226572726F72223A2022666F732D416C6572742D2D64616E676572222C0A202020202020202020202020227761726E696E67223A2022666F732D416C65';
wwv_flow_api.g_varchar2_table(52) := '72742D2D7761726E696E67222C0A20202020202020202020202022696E666F223A2022666F732D416C6572742D2D696E666F220A20202020202020207D3B0A0A20202020202020207661722024746F617374456C656D656E74203D202428273C64697620';
wwv_flow_api.g_varchar2_table(53) := '636C6173733D22666F732D416C65727420666F732D416C6572742D2D686F72697A6F6E74616C20666F732D416C6572742D2D706167652027202B2074797065436C6173735B636F6E6669672E747970655D202B20272220726F6C653D22616C657274223E';
wwv_flow_api.g_varchar2_table(54) := '3C2F6469763E27293B0A20202020202020207661722024746F61737457726170203D202428273C64697620636C6173733D22666F732D416C6572742D77726170223E27293B0A2020202020202020766172202469636F6E57726170203D202428273C6469';
wwv_flow_api.g_varchar2_table(55) := '7620636C6173733D22666F732D416C6572742D69636F6E223E3C2F6469763E27293B0A2020202020202020766172202469636F6E456C656D203D202428273C7370616E20636C6173733D22742D49636F6E2066612027202B2028636F6E6669672E69636F';
wwv_flow_api.g_varchar2_table(56) := '6E436C617373207C7C2069636F6E436C61737365735B636F6E6669672E747970655D29202B2027223E3C2F7370616E3E27293B0A20202020202020207661722024636F6E74656E74456C656D203D202428273C64697620636C6173733D22666F732D416C';
wwv_flow_api.g_varchar2_table(57) := '6572742D636F6E74656E74223E3C2F6469763E27293B0A202020202020202076617220247469746C65456C656D656E74203D202428273C683220636C6173733D22666F732D416C6572742D7469746C65223E3C2F68323E27293B0A202020202020202076';
wwv_flow_api.g_varchar2_table(58) := '617220246D657373616765456C656D656E74203D202428273C64697620636C6173733D22666F732D416C6572742D626F6479223E3C2F6469763E27293B0A20202020202020207661722024627574746F6E57726170706572203D202428273C6469762063';
wwv_flow_api.g_varchar2_table(59) := '6C6173733D22666F732D416C6572742D627574746F6E73223E3C2F6469763E27293B0A20202020202020207661722024636C6F7365456C656D656E743B0A0A2020202020202020696620286469736D6973734F6E427574746F6E29207B0A202020202020';
wwv_flow_api.g_varchar2_table(60) := '20202020202024636C6F7365456C656D656E74203D202428273C627574746F6E20636C6173733D22742D427574746F6E20742D427574746F6E2D2D6E6F554920742D427574746F6E2D2D69636F6E20742D427574746F6E2D2D636C6F7365416C65727422';
wwv_flow_api.g_varchar2_table(61) := '20747970653D22627574746F6E22207469746C653D22436C6F7365204E6F74696669636174696F6E223E3C7370616E20636C6173733D22742D49636F6E2069636F6E2D636C6F7365223E3C2F7370616E3E3C2F627574746F6E3E27293B0A202020202020';
wwv_flow_api.g_varchar2_table(62) := '20207D0A0A202020202020202024746F617374456C656D656E742E617070656E642824746F61737457726170293B0A202020202020202024746F617374577261702E617070656E64282469636F6E57726170293B0A20202020202020202469636F6E5772';
wwv_flow_api.g_varchar2_table(63) := '61702E617070656E64282469636F6E456C656D293B0A202020202020202024746F617374577261702E617070656E642824636F6E74656E74456C656D293B0A202020202020202024636F6E74656E74456C656D2E617070656E6428247469746C65456C65';
wwv_flow_api.g_varchar2_table(64) := '6D656E74293B0A202020202020202024636F6E74656E74456C656D2E617070656E6428246D657373616765456C656D656E74293B0A202020202020202024746F617374577261702E617070656E642824627574746F6E57726170706572293B0A0A202020';
wwv_flow_api.g_varchar2_table(65) := '2020202020696620286469736D6973734F6E427574746F6E29207B0A20202020202020202020202024627574746F6E577261707065722E617070656E642824636C6F7365456C656D656E74293B0A20202020202020207D0A0A20202020202020202F2F20';
wwv_flow_api.g_varchar2_table(66) := '73657474696E6720746865207469746C650A2020202020202020766172207469746C65203D20636F6E6669672E7469746C653B0A2020202020202020696620287469746C6529207B0A20202020202020202020202069662028636F6E6669672E65736361';
wwv_flow_api.g_varchar2_table(67) := '706548746D6C29207B0A202020202020202020202020202020207469746C65203D20617065782E7574696C2E65736361706548544D4C287469746C65293B0A2020202020202020202020207D0A202020202020202020202020247469746C65456C656D65';
wwv_flow_api.g_varchar2_table(68) := '6E742E617070656E64287469746C65293B0A20202020202020207D0A0A20202020202020202F2F73657474696E6720746865206D6573736167650A2020202020202020766172206D657373616765203D20636F6E6669672E6D6573736167653B0A202020';
wwv_flow_api.g_varchar2_table(69) := '2020202020696620286D65737361676529207B0A20202020202020202020202069662028636F6E6669672E65736361706548746D6C20262620747970656F66206D657373616765203D3D2027737472696E6727297B0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(70) := '20206D657373616765203D20617065782E7574696C2E65736361706548544D4C286D657373616765293B0A2020202020202020202020207D0A202020202020202020202020246D657373616765456C656D656E742E617070656E64286D65737361676529';
wwv_flow_api.g_varchar2_table(71) := '3B0A20202020202020207D0A0A20202020202020202F2F2061766F6964696E67206475706C6963617465732C20627574206F6E6C7920636F6E7365637574697665206F6E65730A202020202020202069662028636F6E6669672E70726576656E74447570';
wwv_flow_api.g_varchar2_table(72) := '6C6963617465732026262070726576696F7573546F6173742026262070726576696F7573546F6173742E24656C656D2026262070726576696F7573546F6173742E24656C656D2E697328273A76697369626C65272929207B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(73) := '206966202870726576696F7573546F6173742E7469746C65203D3D207469746C652026262070726576696F7573546F6173742E6D657373616765203D3D206D65737361676529207B0A2020202020202020202020202020202072657475726E3B0A202020';
wwv_flow_api.g_varchar2_table(74) := '2020202020202020207D0A20202020202020207D0A0A202020202020202070726576696F7573546F617374203D207B0A20202020202020202020202024656C656D3A2024746F617374456C656D656E742C0A2020202020202020202020207469746C653A';
wwv_flow_api.g_varchar2_table(75) := '207469746C652C0A2020202020202020202020206D6573736167653A206D6573736167650A20202020202020207D3B0A0A20202020202020202F2F206F7074696F6E616C6C7920636C65617220616C6C206D657373616765732066697273740A20202020';
wwv_flow_api.g_varchar2_table(76) := '2020202069662028636F6E6669672E636C656172416C6C29207B0A202020202020202020202020636C656172416C6C28293B0A20202020202020207D0A20202020202020202F2F206164647320746865206E6F74696669636174696F6E20746F20746865';

wwv_flow_api.g_varchar2_table(77) := '20636F6E7461696E65720A202020202020202069662028636F6E6669672E6E65776573744F6E546F7029207B0A20202020202020202020202024636F6E7461696E65722E70726570656E642824746F617374456C656D656E74293B0A2020202020202020';
wwv_flow_api.g_varchar2_table(78) := '7D20656C7365207B0A20202020202020202020202024636F6E7461696E65722E617070656E642824746F617374456C656D656E74293B0A20202020202020207D0A0A20202020202020202F2F2073657474696E672074686520636F727265637420415249';
wwv_flow_api.g_varchar2_table(79) := '412076616C75650A2020202020202020766172206172696156616C75653B0A20202020202020207377697463682028636F6E6669672E7479706529207B0A20202020202020202020202063617365202773756363657373273A0A20202020202020202020';
wwv_flow_api.g_varchar2_table(80) := '2020636173652027696E666F273A0A202020202020202020202020202020206172696156616C7565203D2027706F6C697465273B0A20202020202020202020202020202020627265616B3B0A20202020202020202020202064656661756C743A0A202020';
wwv_flow_api.g_varchar2_table(81) := '202020202020202020202020206172696156616C7565203D2027617373657274697665273B0A20202020202020207D0A202020202020202024746F617374456C656D656E742E617474722827617269612D6C697665272C206172696156616C7565293B0A';
wwv_flow_api.g_varchar2_table(82) := '0A20202020202020202F2F73657474696E672074696D657220616E642070726F6772657373206261720A2020202020202020766172202470726F6772657373456C656D656E74203D202428273C6469762F3E27293B0A202020202020202069662028636F';
wwv_flow_api.g_varchar2_table(83) := '6E6669672E6469736D6973734166746572203E203029207B0A2020202020202020202020202470726F6772657373456C656D656E742E616464436C6173732827666F7374722D70726F677265737327293B0A20202020202020202020202024746F617374';
wwv_flow_api.g_varchar2_table(84) := '456C656D656E742E617070656E64282470726F6772657373456C656D656E74293B0A0A2020202020202020202020207661722074696D656F75744964203D2073657454696D656F75742866756E6374696F6E2829207B0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(85) := '20202024746F617374456C656D656E742E72656D6F766528293B0A2020202020202020202020207D2C20636F6E6669672E6469736D6973734166746572293B0A2020202020202020202020207661722070726F67726573735374617274416E696D44656C';
wwv_flow_api.g_varchar2_table(86) := '6179203D203130303B0A0A2020202020202020202020202470726F6772657373456C656D656E742E637373287B0A20202020202020202020202020202020277769647468273A202731303025272C0A20202020202020202020202020202020277472616E';
wwv_flow_api.g_varchar2_table(87) := '736974696F6E273A202777696474682027202B202828636F6E6669672E6469736D6973734166746572202D2070726F67726573735374617274416E696D44656C6179292F3130303029202B202773206C696E656172270A2020202020202020202020207D';
wwv_flow_api.g_varchar2_table(88) := '293B0A20202020202020202020202073657454696D656F75742866756E6374696F6E28297B0A202020202020202020202020202020202470726F6772657373456C656D656E742E63737328277769647468272C20273027293B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(89) := '20207D2C2070726F67726573735374617274416E696D44656C6179293B0A0A2020202020202020202020202F2F206F6E20686F766572206F7220636C69636B2C2072656D6F7665207468652074696D657220616E642070726F6772657373206261720A20';
wwv_flow_api.g_varchar2_table(90) := '202020202020202020202024746F617374456C656D656E742E6F6E28276D6F7573656F76657220636C69636B272C2066756E6374696F6E2829207B0A20202020202020202020202020202020636C65617254696D656F75742874696D656F75744964293B';
wwv_flow_api.g_varchar2_table(91) := '0A202020202020202020202020202020202470726F6772657373456C656D656E742E72656D6F766528293B0A2020202020202020202020207D293B0A20202020202020207D0A0A20202020202020202F2F68616E646C696E6720616E79206576656E7473';
wwv_flow_api.g_varchar2_table(92) := '0A2020202020202020696620286469736D6973734F6E436C69636B29207B0A20202020202020202020202024746F617374456C656D656E742E6F6E2827636C69636B272C2066756E6374696F6E286576656E7429207B0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(93) := '2020202F2F20646F206E6F74206469736D6973732069662074686520636C69636B656420656C656D656E7420697320616E20616E63686F72206F72206120627574746F6E0A202020202020202020202020202020206966285B2741272C2027425554544F';
wwv_flow_api.g_varchar2_table(94) := '4E275D2E696E636C756465732824286576656E742E746172676574292E70726F7028276E6F64654E616D65272929297B0A202020202020202020202020202020202020202072657475726E3B0A202020202020202020202020202020207D0A0A20202020';
wwv_flow_api.g_varchar2_table(95) := '2020202020202020202020202F2F20646F206E6F74206469736D6973732069662074686520757365722069732073656C656374696E6720746578740A202020202020202020202020202020207661722073656C656374696F6E203D2077696E646F772E67';
wwv_flow_api.g_varchar2_table(96) := '657453656C656374696F6E28293B0A202020202020202020202020202020206966282073656C656374696F6E202626200A202020202020202020202020202020202020202073656C656374696F6E2E74797065203D3D202752616E6765272026260A2020';
wwv_flow_api.g_varchar2_table(97) := '20202020202020202020202020202020202073656C656374696F6E2E616E63686F724E6F64652026260A2020202020202020202020202020202020202020242873656C656374696F6E2E616E63686F724E6F64652C2024746F617374456C656D656E7429';
wwv_flow_api.g_varchar2_table(98) := '2E6C656E677468203E2030297B0A202020202020202020202020202020202020202072657475726E3B0A202020202020202020202020202020207D0A0A2020202020202020202020202020202024746F617374456C656D656E742E72656D6F766528293B';
wwv_flow_api.g_varchar2_table(99) := '0A2020202020202020202020207D293B0A20202020202020207D0A0A2020202020202020696620286469736D6973734F6E427574746F6E29207B0A20202020202020202020202024636C6F7365456C656D656E742E6F6E2827636C69636B272C2066756E';
wwv_flow_api.g_varchar2_table(100) := '6374696F6E2829207B0A2020202020202020202020202020202024746F617374456C656D656E742E72656D6F766528293B0A2020202020202020202020207D293B0A20202020202020207D0A0A20202020202020202F2F20706572686170732074686520';
wwv_flow_api.g_varchar2_table(101) := '646576656C6F7065722077616E747320746F20646F20736F6D657468696E67206164646974696F6E616C6C79207768656E20746865206E6F74696669636174696F6E20697320636C69636B65640A202020202020202069662028747970656F6620636F6E';
wwv_flow_api.g_varchar2_table(102) := '6669672E6F6E636C69636B203D3D3D202766756E6374696F6E2729207B0A20202020202020202020202024746F617374456C656D656E742E6F6E2827636C69636B272C20636F6E6669672E6F6E636C69636B293B0A202020202020202020202020696620';
wwv_flow_api.g_varchar2_table(103) := '286469736D6973734F6E427574746F6E292024636C6F7365456C656D656E742E6F6E2827636C69636B272C20636F6E6669672E6F6E636C69636B293B0A20202020202020207D0A0A202020202020202072657475726E2024746F617374456C656D656E74';
wwv_flow_api.g_varchar2_table(104) := '3B0A202020207D0A0A2020202072657475726E207B0A2020202020202020737563636573733A20737563636573732C0A2020202020202020696E666F3A20696E666F2C0A20202020202020207761726E696E673A207761726E696E672C0A202020202020';
wwv_flow_api.g_varchar2_table(105) := '20206572726F723A206572726F722C0A2020202020202020636C656172416C6C3A20636C656172416C6C2C0A202020202020202076657273696F6E3A202732302E322E30270A202020207D3B0A0A7D2928293B';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(44318230623558856)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_file_name=>'js/fostr.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A0A0A094E6F7465730A09092A206162736F6C757465206C65667420616E642072696768742076616C7565732073686F756C64206E6F7720626520706C61636573206F6E2074686520636F6E7461696E657220656C656D656E742C206E6F7420746865';
wwv_flow_api.g_varchar2_table(2) := '20696E646976696475616C206E6F74696669636174696F6E730A0A2A2F0A2F2A2A0A202A204669786573206C696E6B207374796C696E6720696E206572726F72730A202A2F0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761';
wwv_flow_api.g_varchar2_table(3) := '726E696E6720612C0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D64616E6765722061207B0A2020636F6C6F723A20696E68657269743B0A2020746578742D6465636F726174696F6E3A20756E6465726C696E653B0A7D0A2F2A';
wwv_flow_api.g_varchar2_table(4) := '2A0A202A20436F6C6F72697A6564204261636B67726F756E640A202A2F0A2E666F732D416C6572742D2D686F72697A6F6E74616C207B0A2020626F726465722D7261646975733A203270783B0A7D0A2E666F732D416C6572742D69636F6E202E742D4963';
wwv_flow_api.g_varchar2_table(5) := '6F6E207B0A2020636F6C6F723A20234646463B0A7D0A2F2A2A0A20202A204D6F6469666965723A205761726E696E670A20202A2F0A2E666F732D416C6572742D2D7761726E696E67202E666F732D416C6572742D69636F6E202E742D49636F6E207B0A20';
wwv_flow_api.g_varchar2_table(6) := '20636F6C6F723A20236662636634613B0A7D0A2E666F732D416C6572742D2D7761726E696E672E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E207B0A20206261636B67726F756E642D636F6C6F723A2072';
wwv_flow_api.g_varchar2_table(7) := '676261283235312C203230372C2037342C20302E3135293B0A7D0A2F2A2A0A20202A204D6F6469666965723A20537563636573730A20202A2F0A2E666F732D416C6572742D2D73756363657373202E666F732D416C6572742D69636F6E202E742D49636F';
wwv_flow_api.g_varchar2_table(8) := '6E207B0A2020636F6C6F723A20233342414132433B0A7D0A2E666F732D416C6572742D2D737563636573732E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E207B0A20206261636B67726F756E642D636F6C';
wwv_flow_api.g_varchar2_table(9) := '6F723A20726762612835392C203137302C2034342C20302E3135293B0A7D0A2F2A2A0A20202A204D6F6469666965723A20496E666F726D6174696F6E0A20202A2F0A2E666F732D416C6572742D2D696E666F202E666F732D416C6572742D69636F6E202E';
wwv_flow_api.g_varchar2_table(10) := '742D49636F6E207B0A2020636F6C6F723A20233030373664663B0A7D0A2E666F732D416C6572742D2D696E666F2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E207B0A20206261636B67726F756E642D63';
wwv_flow_api.g_varchar2_table(11) := '6F6C6F723A207267626128302C203131382C203232332C20302E3135293B0A7D0A2F2A2A0A20202A204D6F6469666965723A20537563636573730A20202A2F0A2E666F732D416C6572742D2D64616E676572202E666F732D416C6572742D69636F6E202E';
wwv_flow_api.g_varchar2_table(12) := '742D49636F6E207B0A2020636F6C6F723A20236634343333363B0A7D0A2E666F732D416C6572742D2D64616E6765722E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E207B0A20206261636B67726F756E64';
wwv_flow_api.g_varchar2_table(13) := '2D636F6C6F723A2072676261283234342C2036372C2035342C20302E3135293B0A7D0A2E666F732D416C6572742D2D686F72697A6F6E74616C207B0A20206261636B67726F756E642D636F6C6F723A20236666666666663B0A2020636F6C6F723A202332';
wwv_flow_api.g_varchar2_table(14) := '36323632363B0A7D0A2F2A0A2E666F732D416C6572742D2D64616E6765727B0A094062673A206C69676874656E2840675F44616E6765722D42472C20343025293B0A096261636B67726F756E642D636F6C6F723A204062673B0A09636F6C6F723A206661';
wwv_flow_api.g_varchar2_table(15) := '646528636F6E7472617374284062672C2064657361747572617465286461726B656E284062672C202031303025292C2031303025292C2064657361747572617465286C69676874656E284062672C202031303025292C2035302529292C2031303025293B';
wwv_flow_api.g_varchar2_table(16) := '0A7D0A2E666F732D416C6572742D2D696E666F207B0A094062673A206C69676874656E2840675F496E666F2D42472C20353525293B0A096261636B67726F756E642D636F6C6F723A204062673B0A09636F6C6F723A206661646528636F6E747261737428';
wwv_flow_api.g_varchar2_table(17) := '4062672C2064657361747572617465286461726B656E284062672C202031303025292C2031303025292C2064657361747572617465286C69676874656E284062672C202031303025292C2035302529292C2031303025293B0A7D0A2A2F0A2E666F732D41';
wwv_flow_api.g_varchar2_table(18) := '6C6572742D2D706167652E666F732D416C6572742D2D73756363657373207B0A20206261636B67726F756E642D636F6C6F723A20726762612835392C203137302C2034342C20302E39293B0A2020636F6C6F723A20234646463B0A7D0A2E666F732D416C';
wwv_flow_api.g_varchar2_table(19) := '6572742D2D706167652E666F732D416C6572742D2D73756363657373202E666F732D416C6572742D69636F6E207B0A20206261636B67726F756E642D636F6C6F723A207472616E73706172656E743B0A2020636F6C6F723A20234646463B0A7D0A2E666F';
wwv_flow_api.g_varchar2_table(20) := '732D416C6572742D2D706167652E666F732D416C6572742D2D73756363657373202E666F732D416C6572742D69636F6E202E742D49636F6E207B0A2020636F6C6F723A20696E68657269743B0A7D0A2E666F732D416C6572742D2D706167652E666F732D';
wwv_flow_api.g_varchar2_table(21) := '416C6572742D2D73756363657373202E742D427574746F6E2D2D636C6F7365416C657274207B0A2020636F6C6F723A20234646462021696D706F7274616E743B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E69';
wwv_flow_api.g_varchar2_table(22) := '6E67207B0A20206261636B67726F756E642D636F6C6F723A20236662636634613B0A2020636F6C6F723A20233434333430323B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E666F732D416C657274';
wwv_flow_api.g_varchar2_table(23) := '2D69636F6E207B0A20206261636B67726F756E642D636F6C6F723A207472616E73706172656E743B0A2020636F6C6F723A20233434333430323B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E666F';
wwv_flow_api.g_varchar2_table(24) := '732D416C6572742D69636F6E202E742D49636F6E207B0A2020636F6C6F723A20696E68657269743B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E742D427574746F6E2D2D636C6F7365416C657274';
wwv_flow_api.g_varchar2_table(25) := '207B0A2020636F6C6F723A20234646462021696D706F7274616E743B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D696E666F207B0A20206261636B67726F756E642D636F6C6F723A20233030373664663B0A2020636F6C';
wwv_flow_api.g_varchar2_table(26) := '6F723A20234646463B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D696E666F202E666F732D416C6572742D69636F6E207B0A20206261636B67726F756E642D636F6C6F723A207472616E73706172656E743B0A2020636F';
wwv_flow_api.g_varchar2_table(27) := '6C6F723A20234646463B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D696E666F202E666F732D416C6572742D69636F6E202E742D49636F6E207B0A2020636F6C6F723A20696E68657269743B0A7D0A2E666F732D416C65';
wwv_flow_api.g_varchar2_table(28) := '72742D2D706167652E666F732D416C6572742D2D696E666F202E742D427574746F6E2D2D636C6F7365416C657274207B0A2020636F6C6F723A20234646462021696D706F7274616E743B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C';
wwv_flow_api.g_varchar2_table(29) := '6572742D2D64616E676572207B0A20206261636B67726F756E642D636F6C6F723A20236634343333363B0A2020636F6C6F723A20234646463B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D64616E676572202E666F732D';
wwv_flow_api.g_varchar2_table(30) := '416C6572742D69636F6E207B0A20206261636B67726F756E642D636F6C6F723A207472616E73706172656E743B0A2020636F6C6F723A20234646463B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D64616E676572202E66';
wwv_flow_api.g_varchar2_table(31) := '6F732D416C6572742D69636F6E202E742D49636F6E207B0A2020636F6C6F723A20696E68657269743B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D64616E676572202E742D427574746F6E2D2D636C6F7365416C657274';
wwv_flow_api.g_varchar2_table(32) := '207B0A2020636F6C6F723A20234646462021696D706F7274616E743B0A7D0A2F2A20486F72697A6F6E74616C20416C657274203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(33) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0A2E666F732D416C6572742D2D686F72697A6F6E74616C207B0A20206D617267696E2D626F74746F6D3A20312E3672656D3B0A2020706F736974696F6E3A2072656C61746976653B';
wwv_flow_api.g_varchar2_table(34) := '0A7D0A2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D77726170207B0A2020646973706C61793A20666C65783B0A2020666C65782D646972656374696F6E3A20726F773B0A7D0A2E666F732D416C6572742D2D686F';
wwv_flow_api.g_varchar2_table(35) := '72697A6F6E74616C202E666F732D416C6572742D69636F6E207B0A202070616464696E673A203020313670783B0A2020666C65782D736872696E6B3A20303B0A2020646973706C61793A20666C65783B0A2020616C69676E2D6974656D733A2063656E74';
wwv_flow_api.g_varchar2_table(36) := '65723B0A7D0A2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D636F6E74656E74207B0A202070616464696E673A20313670783B0A2020666C65783A203120303B0A2020646973706C61793A20666C65783B0A202066';
wwv_flow_api.g_varchar2_table(37) := '6C65782D646972656374696F6E3A20636F6C756D6E3B0A20206A7573746966792D636F6E74656E743A2063656E7465723B0A7D0A2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D627574746F6E73207B0A2020666C';
wwv_flow_api.g_varchar2_table(38) := '65782D736872696E6B3A20303B0A2020746578742D616C69676E3A2072696768743B0A202077686974652D73706163653A206E6F777261703B0A202070616464696E672D72696768743A20312E3672656D3B0A2020646973706C61793A20666C65783B0A';
wwv_flow_api.g_varchar2_table(39) := '2020616C69676E2D6974656D733A2063656E7465723B0A7D0A2E752D52544C202E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D627574746F6E73207B0A202070616464696E672D72696768743A20303B0A20207061';
wwv_flow_api.g_varchar2_table(40) := '6464696E672D6C6566743A20312E3672656D3B0A7D0A2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D627574746F6E733A656D707479207B0A2020646973706C61793A206E6F6E653B0A7D0A2E666F732D416C6572';
wwv_flow_api.g_varchar2_table(41) := '742D2D686F72697A6F6E74616C202E666F732D416C6572742D7469746C65207B0A2020666F6E742D73697A653A203272656D3B0A20206C696E652D6865696768743A20322E3472656D3B0A20206D617267696E2D626F74746F6D3A20303B0A7D0A2E666F';
wwv_flow_api.g_varchar2_table(42) := '732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D626F64793A656D707479207B0A2020646973706C61793A206E6F6E653B0A7D0A2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F';
wwv_flow_api.g_varchar2_table(43) := '6E202E742D49636F6E207B0A2020666F6E742D73697A653A20333270783B0A202077696474683A20333270783B0A2020746578742D616C69676E3A2063656E7465723B0A20206865696768743A20333270783B0A20206C696E652D6865696768743A2031';
wwv_flow_api.g_varchar2_table(44) := '3B0A7D0A2F2A203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D20436F6D6D6F6E2050726F7065727469657320';
wwv_flow_api.g_varchar2_table(45) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0A2E666F732D416C6572742D2D686F72697A6F6E74616C';
wwv_flow_api.g_varchar2_table(46) := '207B0A2020626F726465723A2031707820736F6C6964207267626128302C20302C20302C20302E31293B0A2020626F782D736861646F773A20302032707820347078202D327078207267626128302C20302C20302C20302E303735293B0A7D0A2E666F73';
wwv_flow_api.g_varchar2_table(47) := '2D416C6572742D2D6E6F49636F6E2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E207B0A2020646973706C61793A206E6F6E652021696D706F7274616E743B0A7D0A2E666F732D416C6572742D2D6E6F49';
wwv_flow_api.g_varchar2_table(48) := '636F6E202E666F732D416C6572742D69636F6E202E742D49636F6E207B0A2020646973706C61793A206E6F6E653B0A7D0A2E742D426F64792D616C657274207B0A20206D617267696E3A20303B0A7D0A2E742D426F64792D616C657274202E666F732D41';
wwv_flow_api.g_varchar2_table(49) := '6C657274207B0A20206D617267696E2D626F74746F6D3A20303B0A7D0A2F2A2050616765204E6F74696669636174696F6E202853756363657373206F72204D65737361676529203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(50) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0A2E666F732D416C6572742D2D70616765207B0A20207472616E736974696F6E3A20302E327320656173652D6F75743B0A20206D';
wwv_flow_api.g_varchar2_table(51) := '61782D77696474683A2036343070783B0A20206D696E2D77696474683A2033323070783B0A20202F2A706F736974696F6E3A2066697865643B20746F703A20312E3672656D3B2072696768743A20312E3672656D3B2A2F0A20207A2D696E6465783A2031';
wwv_flow_api.g_varchar2_table(52) := '3030303B0A2020626F726465722D77696474683A20303B0A2020626F782D736861646F773A20302030203020302E3172656D207267626128302C20302C20302C20302E312920696E7365742C20302033707820397078202D327078207267626128302C20';
wwv_flow_api.g_varchar2_table(53) := '302C20302C20302E31293B0A20202F2A20466F72207665727920736D616C6C2073637265656E732C2066697420746865206D65737361676520746F2074686520746F70206F66207468652073637265656E202A2F0A20202F2A2053657420426F72646572';
wwv_flow_api.g_varchar2_table(54) := '2052616469757320746F2030206173206D657373616765206578697374732077697468696E20636F6E74656E74202A2F0A20202F2A2050616765204C6576656C205761726E696E6720616E64204572726F7273203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(55) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0A20202F2A205363726F6C6C62617273202A2F0A7D0A2E666F732D416C6572742D2D7061676520';
wwv_flow_api.g_varchar2_table(56) := '2E666F732D416C6572742D627574746F6E73207B0A202070616464696E672D72696768743A20303B0A7D0A2E666F732D416C6572742D2D70616765202E666F732D416C6572742D69636F6E207B0A202070616464696E672D6C6566743A20312E3672656D';
wwv_flow_api.g_varchar2_table(57) := '3B0A202070616464696E672D72696768743A203870783B0A7D0A2E752D52544C202E666F732D416C6572742D2D70616765202E666F732D416C6572742D69636F6E207B0A202070616464696E672D6C6566743A203870783B0A202070616464696E672D72';
wwv_flow_api.g_varchar2_table(58) := '696768743A20312E3672656D3B0A7D0A2E666F732D416C6572742D2D70616765202E666F732D416C6572742D69636F6E202E742D49636F6E207B0A2020666F6E742D73697A653A20323470783B0A202077696474683A20323470783B0A20206865696768';
wwv_flow_api.g_varchar2_table(59) := '743A20323470783B0A20206C696E652D6865696768743A20313B0A7D0A2E666F732D416C6572742D2D70616765202E666F732D416C6572742D626F6479207B0A202070616464696E672D626F74746F6D3A203870783B0A7D0A2E666F732D416C6572742D';
wwv_flow_api.g_varchar2_table(60) := '2D70616765202E666F732D416C6572742D636F6E74656E74207B0A202070616464696E673A203870783B0A7D0A2E666F732D416C6572742D2D70616765202E742D427574746F6E2D2D636C6F7365416C657274207B0A2020706F736974696F6E3A206162';
wwv_flow_api.g_varchar2_table(61) := '736F6C7574653B0A202072696768743A202D3870783B0A2020746F703A202D3870783B0A202070616464696E673A203470783B0A20206D696E2D77696474683A20303B0A20206261636B67726F756E642D636F6C6F723A20233030302021696D706F7274';
wwv_flow_api.g_varchar2_table(62) := '616E743B0A2020636F6C6F723A20234646462021696D706F7274616E743B0A2020626F782D736861646F773A203020302030203170782072676261283235352C203235352C203235352C20302E3235292021696D706F7274616E743B0A2020626F726465';
wwv_flow_api.g_varchar2_table(63) := '722D7261646975733A20323470783B0A20207472616E736974696F6E3A202D7765626B69742D7472616E73666F726D20302E3132357320656173653B0A20207472616E736974696F6E3A207472616E73666F726D20302E3132357320656173653B0A2020';
wwv_flow_api.g_varchar2_table(64) := '7472616E736974696F6E3A207472616E73666F726D20302E3132357320656173652C202D7765626B69742D7472616E73666F726D20302E3132357320656173653B0A7D0A2E752D52544C202E666F732D416C6572742D2D70616765202E742D427574746F';
wwv_flow_api.g_varchar2_table(65) := '6E2D2D636C6F7365416C657274207B0A202072696768743A206175746F3B0A20206C6566743A202D3870783B0A7D0A2E666F732D416C6572742D2D70616765202E742D427574746F6E2D2D636C6F7365416C6572743A686F766572207B0A20202D776562';
wwv_flow_api.g_varchar2_table(66) := '6B69742D7472616E73666F726D3A207363616C6528312E3135293B0A20207472616E73666F726D3A207363616C6528312E3135293B0A7D0A2E666F732D416C6572742D2D70616765202E742D427574746F6E2D2D636C6F7365416C6572743A6163746976';
wwv_flow_api.g_varchar2_table(67) := '65207B0A20202D7765626B69742D7472616E73666F726D3A207363616C6528302E3835293B0A20207472616E73666F726D3A207363616C6528302E3835293B0A7D0A2F2A2E752D52544C202E666F732D416C6572742D2D70616765207B2072696768743A';
wwv_flow_api.g_varchar2_table(68) := '206175746F3B206C6566743A20312E3672656D3B207D2A2F0A2E666F732D416C6572742D2D706167652E666F732D416C657274207B0A2020626F726465722D7261646975733A20302E3472656D3B0A7D0A2E666F732D416C6572742D2D70616765202E66';
wwv_flow_api.g_varchar2_table(69) := '6F732D416C6572742D7469746C65207B0A202070616464696E673A2038707820303B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E612D4E6F74696669636174696F6E207B0A20206D617267696E2D';
wwv_flow_api.g_varchar2_table(70) := '72696768743A203870783B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E612D4E6F74696669636174696F6E2D7469746C65207B0A2020666F6E742D73697A653A20312E3472656D3B0A20206C696E';
wwv_flow_api.g_varchar2_table(71) := '652D6865696768743A203272656D3B0A2020666F6E742D7765696768743A203730303B0A20206D617267696E3A20303B0A7D0A2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E612D4E6F7469666963617469';
wwv_flow_api.g_varchar2_table(72) := '6F6E2D6C697374207B0A20206D61782D6865696768743A2031323870783B0A7D0A2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6C697374207B0A20206D61782D6865696768743A20393670783B0A20206F76657266';
wwv_flow_api.g_varchar2_table(73) := '6C6F773A206175746F3B0A7D0A2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6C696E6B3A686F766572207B0A2020746578742D6465636F726174696F6E3A20756E6465726C696E653B0A7D0A2E666F732D416C6572';
wwv_flow_api.g_varchar2_table(74) := '742D2D70616765203A3A2D7765626B69742D7363726F6C6C626172207B0A202077696474683A203870783B0A20206865696768743A203870783B0A7D0A2E666F732D416C6572742D2D70616765203A3A2D7765626B69742D7363726F6C6C6261722D7468';
wwv_flow_api.g_varchar2_table(75) := '756D62207B0A20206261636B67726F756E642D636F6C6F723A207267626128302C20302C20302C20302E3235293B0A7D0A2E666F732D416C6572742D2D70616765203A3A2D7765626B69742D7363726F6C6C6261722D747261636B207B0A20206261636B';
wwv_flow_api.g_varchar2_table(76) := '67726F756E642D636F6C6F723A207267626128302C20302C20302C20302E3035293B0A7D0A2E666F732D416C6572742D2D70616765202E666F732D416C6572742D7469746C65207B0A2020646973706C61793A20626C6F636B3B0A2020666F6E742D7765';
wwv_flow_api.g_varchar2_table(77) := '696768743A203730303B0A2020666F6E742D73697A653A20312E3872656D3B0A20206D617267696E2D626F74746F6D3A20303B0A20206D617267696E2D72696768743A20313670783B0A7D0A2E666F732D416C6572742D2D70616765202E666F732D416C';
wwv_flow_api.g_varchar2_table(78) := '6572742D626F6479207B0A20206D617267696E2D72696768743A20313670783B0A7D0A2E752D52544C202E666F732D416C6572742D2D70616765202E666F732D416C6572742D7469746C65207B0A20206D617267696E2D72696768743A20303B0A20206D';
wwv_flow_api.g_varchar2_table(79) := '617267696E2D6C6566743A20313670783B0A7D0A2E752D52544C202E666F732D416C6572742D2D70616765202E666F732D416C6572742D626F6479207B0A20206D617267696E2D72696768743A20303B0A20206D617267696E2D6C6566743A2031367078';
wwv_flow_api.g_varchar2_table(80) := '3B0A7D0A2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6C697374207B0A20206D617267696E3A203470782030203020303B0A202070616464696E673A20303B0A20206C6973742D7374796C653A206E6F6E653B0A7D';
wwv_flow_api.g_varchar2_table(81) := '0A2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D207B0A202070616464696E672D6C6566743A20323070783B0A2020706F736974696F6E3A2072656C61746976653B0A2020666F6E742D73697A653A203134';
wwv_flow_api.g_varchar2_table(82) := '70783B0A20206C696E652D6865696768743A20323070783B0A20206D617267696E2D626F74746F6D3A203470783B0A20202F2A20457874726120536D616C6C2053637265656E73202A2F0A7D0A2E666F732D416C6572742D2D70616765202E612D4E6F74';
wwv_flow_api.g_varchar2_table(83) := '696669636174696F6E2D6974656D3A6C6173742D6368696C64207B0A20206D617267696E2D626F74746F6D3A20303B0A7D0A2E752D52544C202E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D207B0A202070';
wwv_flow_api.g_varchar2_table(84) := '616464696E672D6C6566743A20303B0A202070616464696E672D72696768743A20323070783B0A7D0A2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D3A6265666F7265207B0A2020636F6E74656E743A2027';
wwv_flow_api.g_varchar2_table(85) := '273B0A2020706F736974696F6E3A206162736F6C7574653B0A20206D617267696E3A203870783B0A2020746F703A20303B0A20206C6566743A20303B0A202077696474683A203470783B0A20206865696768743A203470783B0A2020626F726465722D72';
wwv_flow_api.g_varchar2_table(86) := '61646975733A20313030253B0A20206261636B67726F756E642D636F6C6F723A207267626128302C20302C20302C20302E35293B0A7D0A2F2A2E752D52544C202E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D697465';
wwv_flow_api.g_varchar2_table(87) := '6D3A6265666F7265207B2072696768743A20303B206C6566743A206175746F3B207D2A2F0A2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D202E612D427574746F6E2D2D6E6F74696669636174696F6E207B';
wwv_flow_api.g_varchar2_table(88) := '0A202070616464696E673A203270783B0A20206F7061636974793A20302E37353B0A2020766572746963616C2D616C69676E3A20746F703B0A7D0A2E666F732D416C6572742D2D70616765202E68746D6C64624F7261457272207B0A20206D617267696E';
wwv_flow_api.g_varchar2_table(89) := '2D746F703A20302E3872656D3B0A2020646973706C61793A20626C6F636B3B0A2020666F6E742D73697A653A20312E3172656D3B0A20206C696E652D6865696768743A20312E3672656D3B0A2020666F6E742D66616D696C793A20274D656E6C6F272C20';
wwv_flow_api.g_varchar2_table(90) := '27436F6E736F6C6173272C206D6F6E6F73706163652C2073657269663B0A202077686974652D73706163653A207072652D6C696E653B0A7D0A2F2A2041636365737369626C652048656164696E67203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(91) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0A2E666F732D416C6572742D2D61636365737369626C6548656164696E67202E666F732D416C6572742D7469';
wwv_flow_api.g_varchar2_table(92) := '746C65207B0A2020626F726465723A20303B0A2020636C69703A20726563742830203020302030293B0A20206865696768743A203170783B0A20206D617267696E3A202D3170783B0A20206F766572666C6F773A2068696464656E3B0A20207061646469';
wwv_flow_api.g_varchar2_table(93) := '6E673A20303B0A2020706F736974696F6E3A206162736F6C7574653B0A202077696474683A203170783B0A7D0A2F2A2048696464656E2048656164696E6720284E6F742041636365737369626C6529203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(94) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0A2E666F732D416C6572742D2D72656D6F766548656164696E67202E666F732D416C6572742D7469746C65';

wwv_flow_api.g_varchar2_table(95) := '207B0A2020646973706C61793A206E6F6E653B0A7D0A406D6564696120286D61782D77696474683A20343830707829207B0A20202E666F732D416C6572742D2D70616765207B0A202020202F2A6C6566743A20312E3672656D3B2A2F0A202020206D696E';
wwv_flow_api.g_varchar2_table(96) := '2D77696474683A20303B0A202020206D61782D77696474683A206E6F6E653B0A20207D0A20202E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D207B0A20202020666F6E742D73697A653A20313270783B0A20';
wwv_flow_api.g_varchar2_table(97) := '207D0A7D0A406D6564696120286D61782D77696474683A20373638707829207B0A20202E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D7469746C65207B0A20202020666F6E742D73697A653A20312E3872656D3B0A';
wwv_flow_api.g_varchar2_table(98) := '20207D0A7D0A2F2A202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D202A2F0A2F2A20';
wwv_flow_api.g_varchar2_table(99) := '49636F6E2E637373202A2F0A2E666F732D416C657274202E742D49636F6E2E69636F6E2D636C6F73653A6265666F7265207B0A2020666F6E742D66616D696C793A2022617065782D352D69636F6E2D666F6E74223B0A2020646973706C61793A20696E6C';
wwv_flow_api.g_varchar2_table(100) := '696E652D626C6F636B3B0A2020766572746963616C2D616C69676E3A20746F703B0A7D0A2E666F732D416C657274202E742D49636F6E2E69636F6E2D636C6F73653A6265666F7265207B0A20206C696E652D6865696768743A20313670783B0A2020666F';
wwv_flow_api.g_varchar2_table(101) := '6E742D73697A653A20313670783B0A2020636F6E74656E743A20225C65306132223B0A7D0A2F2A202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_api.g_varchar2_table(102) := '2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D202A2F0A2E666F7374722D746F702D63656E746572207B0A2020746F703A20312E3672656D3B0A202072696768743A20303B0A202077696474683A20313030253B0A7D0A2E666F7374722D62';
wwv_flow_api.g_varchar2_table(103) := '6F74746F6D2D63656E746572207B0A2020626F74746F6D3A20312E3672656D3B0A202072696768743A20303B0A202077696474683A20313030253B0A7D0A2E666F7374722D746F702D7269676874207B0A2020746F703A20312E3672656D3B0A20207269';
wwv_flow_api.g_varchar2_table(104) := '6768743A20312E3672656D3B0A7D0A2E666F7374722D746F702D6C656674207B0A2020746F703A20312E3672656D3B0A20206C6566743A20312E3672656D3B0A7D0A2E666F7374722D626F74746F6D2D7269676874207B0A202072696768743A20312E36';
wwv_flow_api.g_varchar2_table(105) := '72656D3B0A2020626F74746F6D3A20312E3672656D3B0A7D0A2E666F7374722D626F74746F6D2D6C656674207B0A2020626F74746F6D3A20312E3672656D3B0A20206C6566743A20312E3672656D3B0A7D0A2E666F7374722D636F6E7461696E6572207B';
wwv_flow_api.g_varchar2_table(106) := '0A2020706F736974696F6E3A2066697865643B0A20207A2D696E6465783A203939393939393B0A2020706F696E7465722D6576656E74733A206E6F6E653B0A20202F2A6F76657272696465732A2F0A7D0A2E666F7374722D636F6E7461696E6572203E20';
wwv_flow_api.g_varchar2_table(107) := '646976207B0A2020706F696E7465722D6576656E74733A206175746F3B0A7D0A2E666F7374722D636F6E7461696E65722E666F7374722D746F702D63656E746572203E206469762C0A2E666F7374722D636F6E7461696E65722E666F7374722D626F7474';
wwv_flow_api.g_varchar2_table(108) := '6F6D2D63656E746572203E20646976207B0A20202F2A77696474683A2033303070783B2A2F0A20206D617267696E2D6C6566743A206175746F3B0A20206D617267696E2D72696768743A206175746F3B0A7D0A2E666F7374722D70726F6772657373207B';
wwv_flow_api.g_varchar2_table(109) := '0A2020706F736974696F6E3A206162736F6C7574653B0A2020626F74746F6D3A20303B0A20206865696768743A203470783B0A20206261636B67726F756E642D636F6C6F723A20626C61636B3B0A20206F7061636974793A20302E343B0A7D0A68746D6C';
wwv_flow_api.g_varchar2_table(110) := '3A6E6F74282E752D52544C29202E666F7374722D70726F6772657373207B0A20206C6566743A20303B0A2020626F726465722D626F74746F6D2D6C6566742D7261646975733A20302E3472656D3B0A7D0A68746D6C2E752D52544C202E666F7374722D70';
wwv_flow_api.g_varchar2_table(111) := '726F6772657373207B0A202072696768743A20303B0A2020626F726465722D626F74746F6D2D72696768742D7261646975733A20302E3472656D3B0A7D0A406D6564696120286D61782D77696474683A20343830707829207B0A20202E666F7374722D63';
wwv_flow_api.g_varchar2_table(112) := '6F6E7461696E6572207B0A202020206C6566743A20312E3672656D3B0A2020202072696768743A20312E3672656D3B0A20207D0A7D0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(44318687584559867)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_file_name=>'css/fostr.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C22736F7572636573223A5B22666F7374722E6A73225D2C226E616D6573223A5B2277696E646F77222C22666F737472222C22434F4E5441494E45525F434C415353222C22746F61737454797065222C2269636F6E436C61';
wwv_flow_api.g_varchar2_table(2) := '73736573222C2273756363657373222C22696E666F222C227761726E696E67222C226572726F72222C22636F6E7461696E657273222C2270726576696F7573546F617374222C226E6F7469667954797065222C2274797065222C226D657373616765222C';
wwv_flow_api.g_varchar2_table(3) := '227469746C65222C226F7074696F6E73222C2266696E616C4F7074696F6E73222C2224222C22657874656E64222C226469736D697373222C226469736D6973734166746572222C226E65776573744F6E546F70222C2270726576656E744475706C696361';
wwv_flow_api.g_varchar2_table(4) := '746573222C2265736361706548746D6C222C22706F736974696F6E222C2269636F6E436C617373222C22636C656172416C6C222C226E6F74696679222C22756E646566696E6564222C2261706578222C226465627567222C226368696C6472656E222C22';
wwv_flow_api.g_varchar2_table(5) := '72656D6F7665222C22636F6E666967222C2224636C6F7365456C656D656E74222C2224636F6E7461696E6572222C22616464436C617373222C22617070656E64222C22637265617465436F6E7461696E6572222C226469736D6973734F6E436C69636B22';
wwv_flow_api.g_varchar2_table(6) := '2C22696E636C75646573222C226469736D6973734F6E427574746F6E222C2224746F617374456C656D656E74222C2224746F61737457726170222C222469636F6E57726170222C222469636F6E456C656D222C2224636F6E74656E74456C656D222C2224';
wwv_flow_api.g_varchar2_table(7) := '7469746C65456C656D656E74222C22246D657373616765456C656D656E74222C2224627574746F6E57726170706572222C227574696C222C2265736361706548544D4C222C2224656C656D222C226973222C226172696156616C7565222C227072657065';
wwv_flow_api.g_varchar2_table(8) := '6E64222C2261747472222C222470726F6772657373456C656D656E74222C2274696D656F75744964222C2273657454696D656F7574222C22637373222C227769647468222C227472616E736974696F6E222C226F6E222C22636C65617254696D656F7574';
wwv_flow_api.g_varchar2_table(9) := '222C226576656E74222C22746172676574222C2270726F70222C2273656C656374696F6E222C2267657453656C656374696F6E222C22616E63686F724E6F6465222C226C656E677468222C226F6E636C69636B222C2276657273696F6E225D2C226D6170';
wwv_flow_api.g_varchar2_table(10) := '70696E6773223A224141734241412C4F41414F432C4D4141512C574145582C49414149432C4541416B422C6B4241456C42432C454143532C55414454412C4541454D2C4F41464E412C454147532C55414854412C4541494F2C51414750432C454141632C';
wwv_flow_api.g_varchar2_table(11) := '43414364432C514141532C6B42414354432C4B41414D2C694241434E432C514141532C3042414354432C4D41414F2C6D42414750432C454141612C47414362432C45414167422C47414570422C53414153432C45414157432C4541414D432C4541415343';
wwv_flow_api.g_varchar2_table(12) := '2C4541414F432C47414574432C49414149432C45414165432C45414145432C4F41414F2C474141492C4341433542432C514141532C434141432C554141572C5941437242432C614141632C4B414364432C614141612C45414362432C6D4241416D422C45';
wwv_flow_api.g_varchar2_table(13) := '41436E42432C594141592C4541435A432C534141552C59414356432C554141572C4B414358432C554141552C47414358582C474147482C4D414175422C694241415A462C47414350412C45414151442C4B41414F412C45414352652C4541414F562C4541';
wwv_flow_api.g_varchar2_table(14) := '4145432C4F41414F462C454141632C4341436A434A2C4B41414D412C47414350432C4B414349412C47414157432C49414362412C47414153442C49414356432C45414151442C45414352412C4F414155652C47414550442C4541414F562C45414145432C';
wwv_flow_api.g_varchar2_table(15) := '4F41414F2C474141472C43414374424E2C4B41414D412C4541434E432C51414153412C45414354432C4D41414F412C47414352452C55414548612C4B41414B432C4D41414D78422C4B41414B2C7345416F4278422C534141536F422C4941434C542C4541';
wwv_flow_api.g_varchar2_table(16) := '41452C6F4241417542632C57414157432C5341694278432C534141534C2C4541414F4D2C4741455A2C4941646B42542C45416D4464552C4541724341432C47416463582C45416359532C4541414F542C53414C3942662C45414157652C4941506C422C53';
wwv_flow_api.g_varchar2_table(17) := '41417942412C47414372422C49414149572C454141616C422C454141452C554141556D422C534141532C534141575A2C47414155592C534141536C432C47414770452C4F414641652C454141452C514141516F422C4F41414F462C4741436A4231422C45';
wwv_flow_api.g_varchar2_table(18) := '414157652C47414159572C4541436842412C4541476F42472C4341416742642C49414F3343652C45414169424E2C4541414F642C5141415171422C534141532C5741437A43432C4541416B42522C4541414F642C5141415171422C534141532C59413042';
wwv_flow_api.g_varchar2_table(19) := '3143452C45414167427A422C454141452C2B4441504E2C4341435A5A2C514141572C7142414358472C4D4141532C6F42414354442C514141572C7142414358442C4B4141512C6D424147714632422C4541414F72422C4D4141512C7942414335472B422C';
wwv_flow_api.g_varchar2_table(20) := '4541416131422C454141452C674341436632422C4541415933422C454141452C734341436434422C4541415935422C454141452C32424141364267422C4541414F522C5741416172422C4541415936422C4541414F72422C4F4141532C61414333466B43';
wwv_flow_api.g_varchar2_table(21) := '2C4541416537422C454141452C794341436A4238422C454141674239422C454141452C714341436C422B422C4541416B422F422C454141452C73434143704267432C454141694268432C454141452C794341476E4277422C49414341502C45414167426A';
wwv_flow_api.g_varchar2_table(22) := '422C454141452C304B4147744279422C454141634C2C4F41414F4D2C4741437242412C454141574E2C4F41414F4F2C4741436C42412C45414155502C4F41414F512C4741436A42462C454141574E2C4F41414F532C4741436C42412C45414161542C4F41';
wwv_flow_api.g_varchar2_table(23) := '414F552C4741437042442C45414161542C4F41414F572C47414370424C2C454141574E2C4F41414F592C47414564522C47414341512C454141655A2C4F41414F482C47414931422C4941414970422C454141516D422C4541414F6E422C4D414366412C49';
wwv_flow_api.g_varchar2_table(24) := '4143496D422C4541414F562C61414350542C45414151652C4B41414B71422C4B41414B432C5741415772432C4941456A4369432C45414163562C4F41414F76422C4941497A422C49414149442C454141556F422C4541414F70422C51415372422C474152';
wwv_flow_api.g_varchar2_table(25) := '49412C494143496F422C4541414F562C59414167432C6942414158562C4941433542412C4541415567422C4B41414B71422C4B41414B432C5741415774432C4941456E436D432C4541416742582C4F41414F78422C4D414976426F422C4541414F582C6D';
wwv_flow_api.g_varchar2_table(26) := '42414171425A2C4741416942412C4541416330432C4F41415331432C4541416330432C4D41414D432C474141472C614143764633432C45414163492C4F414153412C474141534A2C45414163472C53414157412C4741446A452C43417742412C49414149';
wwv_flow_api.g_varchar2_table(27) := '79432C4541434A2C4F416E424135432C45414167422C4341435A30432C4D41414F562C4541435035422C4D41414F412C45414350442C51414153412C474149546F422C4541414F502C55414350412C494147414F2C4541414F5A2C59414350632C454141';
wwv_flow_api.g_varchar2_table(28) := '576F422C51414151622C4741456E42502C45414157452C4F41414F4B2C47414B64542C4541414F72422C4D4143582C4941414B2C5541434C2C4941414B2C4F41434430432C454141592C5341435A2C4D41434A2C51414349412C454141592C5941457042';
wwv_flow_api.g_varchar2_table(29) := '5A2C45414163632C4B41414B2C59414161462C47414768432C49414149472C4541416D4278432C454141452C5541437A422C4741414967422C4541414F622C614141652C454141472C4341437A4271432C454141694272422C534141532C6B4241433142';
wwv_flow_api.g_varchar2_table(30) := '4D2C454141634C2C4F41414F6F422C47414572422C49414149432C45414159432C594141572C57414376426A422C45414163562C57414366432C4541414F622C6341475671432C4541416942472C494141492C4341436A42432C4D4141532C4F41435443';
wwv_flow_api.g_varchar2_table(31) := '2C574141632C5541416137422C4541414F622C61414A542C4B414967442C494141512C614145724675432C594141572C57414350462C4541416942472C494141492C514141532C4F41504C2C4B415737426C422C4541416371422C474141472C6D424141';
wwv_flow_api.g_varchar2_table(32) := '6D422C5741436843432C614141614E2C47414362442C45414169427A422C594171437A422C4F416843494F2C47414341472C4541416371422C474141472C534141532C53414153452C4741452F422C494141472C434141432C4941414B2C554141557A42';
wwv_flow_api.g_varchar2_table(33) := '2C5341415376422C4541414567442C4541414D432C51414151432C4B41414B2C6141416A442C43414B412C49414149432C4541415970452C4F41414F71452C6541436E42442C4741436B422C5341416C42412C4541415578442C4D41435677442C454141';
wwv_flow_api.g_varchar2_table(34) := '55452C5941435672442C454141456D442C45414155452C5741415935422C4741416536422C4F4141532C474149704437422C45414163562C6141496C42532C47414341502C4541416336422C474141472C534141532C574143744272422C45414163562C';
wwv_flow_api.g_varchar2_table(35) := '59414B512C6D4241416E42432C4541414F75432C5541436439422C4541416371422C474141472C5141415339422C4541414F75432C53414337422F422C4741416942502C4541416336422C474141472C5141415339422C4541414F75432C5541476E4439';
wwv_flow_api.g_varchar2_table(36) := '422C474147582C4D41414F2C4341434872432C5141684E4A2C5341416942512C45414153432C4541414F432C47414337422C4F41414F4A2C45414157522C4541416D42552C45414153432C4541414F432C4941674E7244542C4B417A4D4A2C534141634F';
wwv_flow_api.g_varchar2_table(37) := '2C45414153432C4541414F432C47414331422C4F41414F4A2C45414157522C4541416742552C45414153432C4541414F432C4941794D6C44522C5141394D4A2C53414169424D2C45414153432C4541414F432C47414337422C4F41414F4A2C4541415752';
wwv_flow_api.g_varchar2_table(38) := '2C4541416D42552C45414153432C4541414F432C4941384D7244502C4D41764D4A2C534141654B2C45414153432C4541414F432C47414333422C4F41414F4A2C45414157522C4541416942552C45414153432C4541414F432C4941754D6E44572C534141';
wwv_flow_api.g_varchar2_table(39) := '55412C454143562B432C514141532C5541355146222C2266696C65223A22666F7374722E6A73227D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(45157782823815954)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_file_name=>'js/fostr.js.map'
,p_mime_type=>'application/json'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done


