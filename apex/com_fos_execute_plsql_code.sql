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

prompt APPLICATION 102 - FOS Dev
--
-- Application Export:
--   Application:     102
--   Name:            FOS Dev
--   Exported By:     FOS_MASTER_WS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 37441962356114799
--     PLUGIN: 1846579882179407086
--     PLUGIN: 8354320589762683
--     PLUGIN: 50031193176975232
--     PLUGIN: 34175298479606152
--     PLUGIN: 2657630155025963
--     PLUGIN: 35822631205839510
--     PLUGIN: 14934236679644451
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
,p_javascript_file_urls=>'#PLUGIN_FILES#js/script.min.js'
,p_css_file_urls=>'#PLUGIN_FILES#css/style.min.css'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function render',
'    ( p_dynamic_action apex_plugin.t_dynamic_action',
'    , p_plugin         apex_plugin.t_plugin',
'    )',
'return apex_plugin.t_dynamic_action_render_result',
'is',
'    l_result apex_plugin.t_dynamic_action_render_result;',
'    ',
'    l_ajax_id varchar(4000) := apex_plugin.get_ajax_identifier;',
'    ',
'    l_items_to_submit apex_t_varchar2 := apex_string.split(p_dynamic_action.attribute_02, '','');',
'    l_items_to_return apex_t_varchar2 := apex_string.split(p_dynamic_action.attribute_03, '','');',
'    ',
'    l_submit_clob           p_dynamic_action.attribute_06%type := p_dynamic_action.attribute_06;',
'    l_submit_clob_item      p_dynamic_action.attribute_07%type := p_dynamic_action.attribute_07;',
'    l_submit_clob_variable  p_dynamic_action.attribute_08%type := p_dynamic_action.attribute_08;',
'    ',
'    l_return_clob           p_dynamic_action.attribute_09%type := p_dynamic_action.attribute_09;',
'    l_return_clob_item      p_dynamic_action.attribute_10%type := p_dynamic_action.attribute_10;',
'    l_return_clob_variable  p_dynamic_action.attribute_11%type := p_dynamic_action.attribute_11;',
'',
'    --extra options',
'    l_suppress_change_event boolean := instr(p_dynamic_action.attribute_15, ''suppressChangeEvent'') > 0;',
'    l_show_error_as_alert   boolean := instr(p_dynamic_action.attribute_15, ''showErrorAsAlert'')    > 0;',
'',
'begin',
'    ',
'    if apex_application.g_debug then',
'        apex_plugin_util.debug_dynamic_action',
'            ( p_plugin         => p_plugin',
'            , p_dynamic_action => p_dynamic_action',
'            );',
'    end if;',
'    ',
'    apex_json.initialize_clob_output;',
'    apex_json.open_object;',
'',
'    apex_json.write(''ajaxId'',  l_ajax_id);',
'    ',
'    apex_json.open_object(''pageItems'');',
'    apex_json.write(''itemsToSubmit'', l_items_to_submit);',
'    apex_json.write(''itemsToReturn'', l_items_to_return);',
'    apex_json.close_object;',
'',
'',
'    apex_json.open_object(''clobSettings'');',
'    apex_json.write(''submitClob'', l_submit_clob is not null);',
'    apex_json.write(''submitClobFrom'', l_submit_clob);',
'    apex_json.write(''submitClobItem'', l_submit_clob_item);',
'    apex_json.write(''submitClobVariable'', l_submit_clob_variable);',
'    apex_json.write(''returnClob'', l_return_clob is not null);',
'    apex_json.write(''returnClobInto'', l_return_clob);',
'    apex_json.write(''returnClobItem'', l_return_clob_item);',
'    apex_json.write(''returnClobVariable'', l_return_clob_variable);',
'    apex_json.close_object;',
'',
'    apex_json.open_object(''options'');',
'    apex_json.write(''suppressChangeEvent'', l_suppress_change_event);',
'    apex_json.write(''showErrorAsAlert'', l_show_error_as_alert);',
'    apex_json.close_object;',
'',
'    apex_json.close_object;',
'    l_result.javascript_function := ''function(){FOS.execPlSql.executePlSqlCode(this, ''|| apex_json.get_clob_output ||'');}'';',
'    ',
'    apex_json.free_output;',
'    return l_result;',
'end;',
'',
'function ajax',
'    ( p_dynamic_action apex_plugin.t_dynamic_action',
'    , p_plugin         apex_plugin.t_plugin',
'    )',
'return apex_plugin.t_dynamic_action_ajax_result',
'is',
'    l_result           apex_plugin.t_dynamic_action_ajax_result;',
'    ',
'    l_statement        p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;',
'    l_items_to_return  p_dynamic_action.attribute_03%type := p_dynamic_action.attribute_03;',
'    l_success_message  p_dynamic_action.attribute_04%type := p_dynamic_action.attribute_04;',
'    l_error_message    p_dynamic_action.attribute_05%type := p_dynamic_action.attribute_05;',
'    l_return_clob      boolean                            := p_dynamic_action.attribute_09 is not null;',
'    ',
'    l_message          varchar2(4000);',
'    l_item_names       apex_t_varchar2;',
'begin',
'',
'    if apex_application.g_debug then',
'        apex_plugin_util.debug_dynamic_action',
'            ( p_plugin         => p_plugin',
'            , p_dynamic_action => p_dynamic_action',
'            );',
'    end if;',
'    ',
'    apex_exec.execute_plsql(p_plsql_code => l_statement);',
'',
'    apex_json.initialize_output;',
'    apex_json.open_object;',
'',
'    if l_items_to_return is not null then',
'        l_item_names := apex_string.split(l_items_to_return, '','');',
'        ',
'        apex_json.open_array(''items'');',
'        ',
'        for i in 1 .. l_item_names.count loop',
'            apex_json.open_object;',
'            apex_json.write(''id'', apex_plugin_util.item_names_to_dom',
'                ( p_item_names     => l_item_names(i)',
'                , p_dynamic_action => p_dynamic_action',
'                )',
'            );',
'            apex_json.write(''value'', V(l_item_names(i)));',
'            apex_json.close_object;',
'        end loop;',
'',
'        apex_json.close_array;',
'    end if;',
'    ',
'    if l_return_clob then',
'        apex_json.write(''clob'', apex_application.g_clob_01);',
'    end if;',
'    ',
'    apex_json.write(''status'', ''success'');',
'    ',
'    l_message := nvl(apex_application.g_x01, l_success_message);',
'    apex_json.write(''message'', l_message);',
'    ',
'    apex_json.close_object;',
'',
'    return l_result;',
'',
'exception',
'    when others then',
'        rollback;',
'',
'        apex_json.initialize_output;',
'        apex_json.open_object;',
'        apex_json.write(''status'', ''error'');',
'',
'        l_message := nvl(apex_application.g_x02, l_error_message);',
'',
'        l_message := replace(l_message, ''#SQLCODE#'', apex_escape.html(sqlcode));',
'        l_message := replace(l_message, ''#SQLERRM#'', apex_escape.html(sqlerrm));',
'        l_message := replace(l_message, ''#SQLERRM_TEXT#'', apex_escape.html(substr(sqlerrm, instr(sqlerrm, '':'')+1)));',
'',
'        apex_json.write(''message'', l_message);',
'',
'        apex_json.close_object;',
'',
'        return l_result;',
'end;',
''))
,p_api_version=>1
,p_render_function=>'render'
,p_ajax_function=>'ajax'
,p_standard_attributes=>'STOP_EXECUTION_ON_ERROR:WAIT_FOR_RESULT:INIT_JAVASCRIPT_CODE'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'Executes PL/SQL code on the server.'
,p_version_identifier=>'20.1.0'
,p_about_url=>'https://fos.world'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'@fos-export',
'@fos-auto-return-to-page',
'@fos-auto-open-files:js/script.js'))
,p_files_version=>213
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
'<p>In this example, you need to enter <code>P1_SAL,P1_JOB</code> in <strong>Page Items to Submit</strong>.</p>'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Specify an execution only PL/SQL anonymous block, that is executed on the server.</p>',
'<p>You can reference other page or application items from within your application using bind syntax (for example <code>:P1_MY_ITEM</code>). Any items referenced also need to be included in <strong>Page Items to Submit</strong>.</p>'))
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
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Provide a success message which will be displayed as a green alert if the execution is completed successfully.</p>',
'<p>This message can be dynamically overridden in the PL/SQL Code block by assigning the new value to the apex_application.g_x01 global variable.</p>',
'<pre>apex_application.g_x01 := ''New Success Message'';</pre>',
'<p>If no success message is provided, none will be shown.</p>'))
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
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(25856819775231278)
,p_plugin_attribute_id=>wwv_flow_api.id(25850441847216115)
,p_display_sequence=>20
,p_display_value=>'From JavaScript Variable'
,p_return_value=>'javascriptvariable'
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
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(25886582543315830)
,p_plugin_attribute_id=>wwv_flow_api.id(25880250916306983)
,p_display_sequence=>20
,p_display_value=>'Into JavaScript Variable'
,p_return_value=>'javascriptvariable'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(25886996664317732)
,p_plugin_attribute_id=>wwv_flow_api.id(25880250916306983)
,p_display_sequence=>30
,p_display_value=>'Into JavaScript Variable as JSON'
,p_return_value=>'javascriptvariablejson'
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
,p_prompt=>'Options'
,p_attribute_type=>'CHECKBOXES'
,p_is_required=>false
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p><b>Suppress Change Event</b></p>',
'<p>Specify whether the change event is suppressed on the items specified in Page Items to Return. This prevents subsequent Change based Dynamic Actions from firing, for these items.</p>',
'<p><b>Show Error as Alert</b></p>',
'<p>By default, errors will be shown via <code>apex.message.showErrors</code> as opposed to <code>apex.message.alert</code>. If you wish to use the classic alert, tick this checkbox.</p>'))
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(25694479033736372)
,p_plugin_attribute_id=>wwv_flow_api.id(25688942823733727)
,p_display_sequence=>10
,p_display_value=>'Suppress Change Event'
,p_return_value=>'suppressChangeEvent'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(25700005476750803)
,p_plugin_attribute_id=>wwv_flow_api.id(25688942823733727)
,p_display_sequence=>20
,p_display_value=>'Show Error as Alert'
,p_return_value=>'showErrorAsAlert'
);
wwv_flow_api.create_plugin_std_attribute(
 p_id=>wwv_flow_api.id(8623304523416305)
,p_plugin_id=>wwv_flow_api.id(1846579882179407086)
,p_name=>'INIT_JAVASCRIPT_CODE'
,p_is_required=>false
,p_depending_on_has_to_exist=>true
,p_help_text=>'123'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '77696E646F772E464F53202020203D2077696E646F772E464F53202020207C7C207B7D3B0A464F532E65786563506C53716C203D20464F532E65786563506C53716C207C7C207B7D3B0A0A464F532E65786563506C53716C2E73686F775370696E6E6572';
wwv_flow_api.g_varchar2_table(2) := '203D2066756E6374696F6E2028636F6E66696729207B0A0A20202020617065782E64656275672E696E666F2827464F53202D204578656375746520504C2F53514C20436F6465272C20636F6E666967293B0A0A202020207661722073656C6563746F7220';
wwv_flow_api.g_varchar2_table(3) := '3D20636F6E6669672E73656C6563746F723B0A2020202076617220646973706C61794F7665726C6179203D20636F6E6669672E646973706C61794F7665726C61793B0A0A20202020766172206C5370696E6E65723B0A20202020766172206C5761697450';
wwv_flow_api.g_varchar2_table(4) := '6F707570243B0A0A2020202069662028646973706C61794F7665726C617929207B0A202020202020202076617220626F64795374796C65203D2027706F736974696F6E3A2066697865643B202020207A2D696E6465783A20313930303B20766973696269';
wwv_flow_api.g_varchar2_table(5) := '6C6974793A2076697369626C653B2077696474683A20313030253B206865696768743A20313030253B206261636B67726F756E643A2072676261283235352C203235352C203235352C20302E35293B273B0A2020202020202020766172206E6F726D616C';
wwv_flow_api.g_varchar2_table(6) := '5374796C65203D2027706F736974696F6E3A206162736F6C7574653B207A2D696E6465783A203434303B20207669736962696C6974793A2076697369626C653B2077696474683A20313030253B206865696768743A20313030253B206261636B67726F75';
wwv_flow_api.g_varchar2_table(7) := '6E643A2072676261283235352C203235352C203235352C20302E35293B273B0A0A20202020202020206C57616974506F70757024203D202428273C646976207374796C653D2227202B202873656C6563746F72203D3D2027626F647927203F20626F6479';
wwv_flow_api.g_varchar2_table(8) := '5374796C65203A206E6F726D616C5374796C6529202B2027223E3C2F6469763E27292E70726570656E64546F28242873656C6563746F7229293B0A202020207D0A0A202020206C5370696E6E6572203D20617065782E7574696C2E73686F775370696E6E';
wwv_flow_api.g_varchar2_table(9) := '65722873656C6563746F722C202873656C6563746F72203D3D2027626F647927203F207B2066697865643A2074727565207D203A207B207370696E6E6572436C6173733A202761752D657865637574652D637573746F6D5370696E6E6572436C61737327';
wwv_flow_api.g_varchar2_table(10) := '207D29293B0A0A2020202072657475726E207B0A202020202020202072656D6F76653A2066756E6374696F6E202829207B0A202020202020202020202020696620286C57616974506F7075702420213D3D20756E646566696E656429207B0A2020202020';
wwv_flow_api.g_varchar2_table(11) := '20202020202020202020206C57616974506F707570242E72656D6F766528293B0A2020202020202020202020207D0A202020202020202020202020696620286C5370696E6E657220213D3D20756E646566696E656429207B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(12) := '20202020206C5370696E6E65722E72656D6F766528293B0A2020202020202020202020207D0A20202020202020207D0A202020207D3B0A7D3B0A0A2F2F6275696C64732061206E6573746564206F626A65637420696620697420646F65736E2774206578';
wwv_flow_api.g_varchar2_table(13) := '69737420616E642061737369676E7320697420612076616C75650A464F532E65786563506C53716C2E6372656174654E65737465644F626A656374416E6441737369676E203D2066756E6374696F6E20286F626A2C206B6579506174682C2076616C7565';
wwv_flow_api.g_varchar2_table(14) := '29207B0A202020206B657950617468203D206B6579506174682E73706C697428272E27293B0A202020206C6173744B6579496E646578203D206B6579506174682E6C656E677468202D20313B0A20202020666F7220287661722069203D20303B2069203C';
wwv_flow_api.g_varchar2_table(15) := '206C6173744B6579496E6465783B202B2B6929207B0A20202020202020206B6579203D206B6579506174685B695D3B0A20202020202020206966202821286B657920696E206F626A2929207B0A2020202020202020202020206F626A5B6B65795D203D20';
wwv_flow_api.g_varchar2_table(16) := '7B7D3B0A20202020202020207D0A20202020202020206F626A203D206F626A5B6B65795D3B0A202020207D0A202020206F626A5B6B6579506174685B6C6173744B6579496E6465785D5D203D2076616C75653B0A7D3B0A0A464F532E65786563506C5371';
wwv_flow_api.g_varchar2_table(17) := '6C2E65786563757465506C53716C436F6465203D2066756E6374696F6E20286461436F6E746578742C20636F6E66696729207B0A20202020617065782E64656275672E696E666F2827464F53202D204578656375746520504C2F53514C20436F64652027';
wwv_flow_api.g_varchar2_table(18) := '2C20636F6E666967293B0A0A2020202076617220616374696F6E203D206461436F6E746578742E616374696F6E3B0A2020202076617220726573756D6543616C6C6261636B203D206461436F6E746578742E726573756D6543616C6C6261636B3B0A2020';
wwv_flow_api.g_varchar2_table(19) := '202076617220616A61784964203D20636F6E6669672E616A617849643B0A2020202076617220706167654974656D73203D20636F6E6669672E706167654974656D733B0A202020202F2F766172206C6F6164657253657474696E6773203D20636F6E6669';
wwv_flow_api.g_varchar2_table(20) := '672E6C6F6164657253657474696E67733B0A2020202076617220636C6F6253657474696E6773203D20636F6E6669672E636C6F6253657474696E67733B0A20202020766172206F7074696F6E73203D20636F6E6669672E6F7074696F6E733B0A0A202020';
wwv_flow_api.g_varchar2_table(21) := '2066756E6374696F6E205F68616E646C65526573706F6E736528704461746129207B0A20202020202020206966202870446174612E737461747573203D3D2027737563636573732729207B0A202020202020202020202020766172206974656D436F756E';
wwv_flow_api.g_varchar2_table(22) := '742C206974656D41727261793B0A2020202020202020202020202F2F726567756C61722070616765206974656D730A2020202020202020202020206966202870446174612026262070446174612E6974656D7329207B0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(23) := '2020206974656D436F756E74203D2070446174612E6974656D732E6C656E6774683B0A202020202020202020202020202020206974656D4172726179203D2070446174612E6974656D733B0A20202020202020202020202020202020666F722028766172';
wwv_flow_api.g_varchar2_table(24) := '2069203D20303B2069203C206974656D436F756E743B20692B2B29207B0A20202020202020202020202020202020202020202473286974656D41727261795B695D2E69642C206974656D41727261795B695D2E76616C75652C206E756C6C2C206F707469';
wwv_flow_api.g_varchar2_table(25) := '6F6E732E73757070726573734368616E67654576656E74293B0A202020202020202020202020202020207D0A2020202020202020202020207D0A0A2020202020202020202020202F2F636C6F622070616765206974656D2F207661726961626C652F2076';
wwv_flow_api.g_varchar2_table(26) := '61726961626C65206173206A736F6E0A20202020202020202020202069662028636C6F6253657474696E67732E72657475726E436C6F6229207B0A202020202020202020202020202020207377697463682028636C6F6253657474696E67732E72657475';
wwv_flow_api.g_varchar2_table(27) := '726E436C6F62496E746F29207B0A2020202020202020202020202020202020202020636173652027706167656974656D273A0A202020202020202020202020202020202020202020202020247328636C6F6253657474696E67732E72657475726E436C6F';
wwv_flow_api.g_varchar2_table(28) := '624974656D2C2070446174612E636C6F622C206E756C6C2C206F7074696F6E732E73757070726573734368616E67654576656E74293B0A202020202020202020202020202020202020202020202020627265616B3B0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(29) := '2020202020206361736520276A6176617363726970747661726961626C65273A0A202020202020202020202020202020202020202020202020464F532E65786563506C53716C2E6372656174654E65737465644F626A656374416E6441737369676E2877';
wwv_flow_api.g_varchar2_table(30) := '696E646F772C20636C6F6253657474696E67732E72657475726E436C6F625661726961626C652C2070446174612E636C6F62293B0A202020202020202020202020202020202020202020202020627265616B3B0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(31) := '202020206361736520276A6176617363726970747661726961626C656A736F6E273A0A202020202020202020202020202020202020202020202020464F532E65786563506C53716C2E6372656174654E65737465644F626A656374416E6441737369676E';
wwv_flow_api.g_varchar2_table(32) := '2877696E646F772C20636C6F6253657474696E67732E72657475726E436C6F625661726961626C652C204A534F4E2E70617273652870446174612E636C6F6229293B0A202020202020202020202020202020202020202020202020627265616B3B0A2020';
wwv_flow_api.g_varchar2_table(33) := '20202020202020202020202020202020202064656661756C743A0A202020202020202020202020202020202020202020202020627265616B3B0A202020202020202020202020202020207D0A2020202020202020202020207D0A0A202020202020202020';
wwv_flow_api.g_varchar2_table(34) := '2020206966202870446174612E6D65737361676529207B0A20202020202020202020202020202020617065782E6D6573736167652E73686F7750616765537563636573732870446174612E6D657373616765293B0A2020202020202020202020207D0A0A';
wwv_flow_api.g_varchar2_table(35) := '2020202020202020202020202F2A20526573756D6520657865637574696F6E206F6620616374696F6E73206865726520616E6420706173732066616C736520746F207468652063616C6C6261636B2C20746F20696E646963617465206E6F0A2020202020';
wwv_flow_api.g_varchar2_table(36) := '202020202020206572726F7220686173206F6363757272656420776974682074686520416A61782063616C6C2E202A2F0A202020202020202020202020617065782E64612E726573756D6528726573756D6543616C6C6261636B2C2066616C7365293B0A';
wwv_flow_api.g_varchar2_table(37) := '20202020202020207D20656C7365206966202870446174612E737461747573203D3D20276572726F722729207B0A2020202020202020202020206966202870446174612E6D65737361676529207B0A0A2020202020202020202020202020202069662028';
wwv_flow_api.g_varchar2_table(38) := '6F7074696F6E732E73686F774572726F724173416C65727429207B0A2020202020202020202020202020202020202020617065782E6D6573736167652E616C6572742870446174612E6D657373616765293B0A202020202020202020202020202020207D';
wwv_flow_api.g_varchar2_table(39) := '20656C7365207B0A20202020202020202020202020202020202020202F2F20466972737420636C65617220746865206572726F72730A2020202020202020202020202020202020202020617065782E6D6573736167652E636C6561724572726F72732829';
wwv_flow_api.g_varchar2_table(40) := '3B0A0A20202020202020202020202020202020202020202F2F204E6F772073686F77206E6577206572726F72730A2020202020202020202020202020202020202020617065782E6D6573736167652E73686F774572726F7273287B0A2020202020202020';
wwv_flow_api.g_varchar2_table(41) := '20202020202020202020202020202020747970653A20276572726F72272C0A2020202020202020202020202020202020202020202020206C6F636174696F6E3A202770616765272C0A2020202020202020202020202020202020202020202020206D6573';
wwv_flow_api.g_varchar2_table(42) := '736167653A2070446174612E6D6573736167652C0A202020202020202020202020202020202020202020202020756E736166653A2066616C73650A20202020202020202020202020202020202020207D293B0A202020202020202020202020202020207D';
wwv_flow_api.g_varchar2_table(43) := '0A2020202020202020202020207D0A20202020202020207D0A202020207D0A0A20202020766172206C5370696E6E6572243B0A2020202076617220756E697175654964203D206E6577204461746528292E67657454696D6528293B0A0A202020202F2A0A';
wwv_flow_api.g_varchar2_table(44) := '20202020696620286C6F6164657253657474696E67732E73686F774
C6F6164657229207B0A2020202020202020617065782E7574696C2E64656C61794C696E6765722E737461727428756E6971756549642C2066756E6374696F6E202829207B0A202020';
wwv_flow_api.g_varchar2_table(45) := '2020202020202020206C5370696E6E657224203D20464F532E65786563506C53716C2E73686F775370696E6E6572287B0A2020202020202020202020202020202073656C6563746F723A206C6F6164657253657474696E67732E6C6F61646572506F7369';
wwv_flow_api.g_varchar2_table(46) := '74696F6E2C0A2020202020202020202020202020202073686F774F7665726C61793A20286C6F6164657253657474696E67732E6C6F6164657254797065203D3D20277370696E6E6572616E646F7665726C617927290A2020202020202020202020207D29';
wwv_flow_api.g_varchar2_table(47) := '3B0A20202020202020207D293B0A202020207D0A202020202A2F0A0A202020202F2A0A202020207661722068616E646C655F7370696E6E6572203D2066756E6374696F6E202829207B0A2020202020202020696620286C6F6164657253657474696E6773';
wwv_flow_api.g_varchar2_table(48) := '2E73686F774C6F6164657229207B0A202020202020202020202020617065782E7574696C2E64656C61794C696E6765722E66696E69736828756E6971756549642C2066756E6374696F6E202829207B0A2020202020202020202020202020202069662028';
wwv_flow_api.g_varchar2_table(49) := '6C5370696E6E65722429207B0A20202020202020202020202020202020202020206C5370696E6E6572242E72656D6F766528293B0A202020202020202020202020202020207D0A2020202020202020202020207D293B0A20202020202020207D0A202020';
wwv_flow_api.g_varchar2_table(50) := '207D3B0A202020202A2F0A0A2020202076617220636C6F62546F5375626D69743B0A0A2020202069662028636C6F6253657474696E67732E7375626D6974436C6F6229207B0A20202020202020207377697463682028636C6F6253657474696E67732E73';
wwv_flow_api.g_varchar2_table(51) := '75626D6974436C6F6246726F6D29207B0A202020202020202020202020636173652027706167656974656D273A0A20202020202020202020202020202020636C6F62546F5375626D6974203D206974656D28636C6F6253657474696E67732E7375626D69';
wwv_flow_api.g_varchar2_table(52) := '74436C6F624974656D292E67657456616C756528293B0A20202020202020202020202020202020627265616B3B0A2020202020202020202020206361736520276A6176617363726970747661726961626C65273A0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(53) := '2076617220746F5375626D6974203D2077696E646F775B636C6F6253657474696E67732E7375626D6974436C6F625661726961626C655D3B0A0A2020202020202020202020202020202069662028746F5375626D697420696E7374616E63656F66204F62';
wwv_flow_api.g_varchar2_table(54) := '6A65637429207B0A2020202020202020202020202020202020202020636C6F62546F5375626D6974203D204A534F4E2E737472696E6769667928746F5375626D6974293B0A202020202020202020202020202020207D20656C7365207B0A202020202020';
wwv_flow_api.g_varchar2_table(55) := '2020202020202020202020202020636C6F62546F5375626D6974203D20746F5375626D69743B0A202020202020202020202020202020207D0A20202020202020202020202020202020627265616B3B0A20202020202020202020202064656661756C743A';
wwv_flow_api.g_varchar2_table(56) := '0A20202020202020202020202020202020627265616B3B0A20202020202020207D0A202020207D0A0A2020202076617220726573756C74203D20617065782E7365727665722E706C7567696E28616A617849642C207B0A20202020202020207061676549';
wwv_flow_api.g_varchar2_table(57) := '74656D733A20706167654974656D732E6974656D73546F5375626D69742C0A2020202020202020705F636C6F625F30313A20636C6F62546F5375626D69740A202020207D2C207B0A202020202020202064617461547970653A20276A736F6E272C0A2020';
wwv_flow_api.g_varchar2_table(58) := '2020202020206C6F6164696E67496E64696361746F723A20706167654974656D732E6974656D73546F52657475726E2E6D6170286974656D203D3E20272327202B206974656D292E6A6F696E28272C27292C0A20202020202020207461726765743A2064';
wwv_flow_api.g_varchar2_table(59) := '61436F6E746578742E62726F777365724576656E742E7461726765740A202020207D293B0A0A20202020726573756C742E646F6E652866756E6374696F6E2864617461297B0A20202020202020205F68616E646C65526573706F6E73652864617461293B';
wwv_flow_api.g_varchar2_table(60) := '0A202020207D292E6661696C2866756E6374696F6E286A715848522C20746578745374617475732C206572726F725468726F776E297B0A2020202020202020617065782E64612E68616E646C65416A61784572726F7273286A715848522C207465787453';
wwv_flow_api.g_varchar2_table(61) := '74617475732C206572726F725468726F776E2C20726573756D6543616C6C6261636B293B0A202020207D292E616C776179732866756E6374696F6E28297B0A20202020202020202F2F68616E646C655F7370696E6E657228293B0A202020207D293B0A7D';
wwv_flow_api.g_varchar2_table(62) := '3B0A';
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
wwv_flow_api.g_varchar2_table(1) := '2E61752D657865637574652D637573746F6D5370696E6E6572436C617373207B0A20202020706F736974696F6E3A206162736F6C7574652021696D706F7274616E743B0A202020206C6566743A20302021696D706F7274616E743B0A2020202072696768';
wwv_flow_api.g_varchar2_table(2) := '743A20302021696D706F7274616E743B0A202020206D617267696E3A206175746F2021696D706F7274616E743B0A20202020746F703A20302021696D706F7274616E743B0A20202020626F74746F6D3A20302021696D706F7274616E743B0A202020207A';
wwv_flow_api.g_varchar2_table(3) := '2D696E6465783A203435303B0A7D';
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
wwv_flow_api.g_varchar2_table(1) := '2E61752D657865637574652D637573746F6D5370696E6E6572436C6173737B706F736974696F6E3A6162736F6C75746521696D706F7274616E743B6C6566743A3021696D706F7274616E743B72696768743A3021696D706F7274616E743B6D617267696E';
wwv_flow_api.g_varchar2_table(2) := '3A6175746F21696D706F7274616E743B746F703A3021696D706F7274616E743B626F74746F6D3A3021696D706F7274616E743B7A2D696E6465783A3435307D0A2F2A2320736F757263654D617070696E6755524C3D7374796C652E6373732E6D61702A2F';
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
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C22736F7572636573223A5B227374796C652E637373225D2C226E616D6573223A5B5D2C226D617070696E6773223A22414141412C38422C434143492C32422C434143412C67422C434143412C69422C434143412C71422C';
wwv_flow_api.g_varchar2_table(2) := '434143412C652C434143412C6B422C434143412C57222C2266696C65223A227374796C652E637373222C22736F7572636573436F6E74656E74223A5B222E61752D657865637574652D637573746F6D5370696E6E6572436C617373207B5C6E2020202070';
wwv_flow_api.g_varchar2_table(3) := '6F736974696F6E3A206162736F6C7574652021696D706F7274616E743B5C6E202020206C6566743A20302021696D706F7274616E743B5C6E2020202072696768743A20302021696D706F7274616E743B5C6E202020206D617267696E3A206175746F2021';
wwv_flow_api.g_varchar2_table(4) := '696D706F7274616E743B5C6E20202020746F703A20302021696D706F7274616E743B5C6E20202020626F74746F6D3A20302021696D706F7274616E743B5C6E202020207A2D696E6465783A203435303B5C6E7D225D7D';
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
wwv_flow_api.g_varchar2_table(1) := '77696E646F772E464F533D77696E646F772E464F537C7C7B7D2C464F532E65786563506C53716C3D464F532E65786563506C53716C7C7C7B7D2C464F532E65786563506C53716C2E73686F775370696E6E65723D66756E6374696F6E2865297B61706578';
wwv_flow_api.g_varchar2_table(2) := '2E64656275672E696E666F2822464F53202D204578656375746520504C2F53514C20436F6465222C65293B76617220732C612C693D652E73656C6563746F723B696628652E646973706C61794F7665726C6179297B613D2428273C646976207374796C65';
wwv_flow_api.g_varchar2_table(3) := '3D22272B2822626F6479223D3D693F22706F736974696F6E3A2066697865643B202020207A2D696E6465783A20313930303B207669736962696C6974793A2076697369626C653B2077696474683A20313030253B206865696768743A20313030253B2062';
wwv_flow_api.g_varchar2_table(4) := '61636B67726F756E643A2072676261283235352C203235352C203235352C20302E35293B223A22706F736974696F6E3A206162736F6C7574653B207A2D696E6465783A203434303B20207669736962696C6974793A2076697369626C653B207769647468';
wwv_flow_api.g_varchar2_table(5) := '3A20313030253B206865696768743A20313030253B206261636B67726F756E643A2072676261283235352C203235352C203235352C20302E35293B22292B27223E3C2F6469763E27292E70726570656E64546F2824286929297D72657475726E20733D61';
wwv_flow_api.g_varchar2_table(6) := '7065782E7574696C2E73686F775370696E6E657228692C22626F6479223D3D693F7B66697865643A21307D3A7B7370696E6E6572436C6173733A2261752D657865637574652D637573746F6D5370696E6E6572436C617373227D292C7B72656D6F76653A';
wwv_flow_api.g_varchar2_table(7) := '66756E6374696F6E28297B766F69642030213D3D612626612E72656D6F766528292C766F69642030213D3D732626732E72656D6F766528297D7D7D2C464F532E65786563506C53716C2E6372656174654E65737465644F626A656374416E644173736967';
wwv_flow_api.g_varchar2_table(8) := '6E3D66756E6374696F6E28652C732C61297B733D732E73706C697428222E22292C6C6173744B6579496E6465783D732E6C656E6774682D313B666F722876617220693D303B693C6C6173744B6579496E6465783B2B2B69296B65793D735B695D2C6B6579';
wwv_flow_api.g_varchar2_table(9) := '20696E20657C7C28655B6B65795D3D7B7D292C653D655B6B65795D3B655B735B6C6173744B6579496E6465785D5D3D617D2C464F532E65786563506C53716C2E65786563757465506C53716C436F64653D66756E6374696F6E28652C73297B617065782E';
wwv_flow_api.g_varchar2_table(10) := '64656275672E696E666F2822464F53202D204578656375746520504C2F53514C20436F646520222C73293B652E616374696F6E3B76617220613D652E726573756D6543616C6C6261636B2C693D732E616A617849642C743D732E706167654974656D732C';
wwv_flow_api.g_varchar2_table(11) := '723D732E636C6F6253657474696E67732C6E3D732E6F7074696F6E733B766172206F3B286E65772044617465292E67657454696D6528293B696628722E7375626D6974436C6F622973776974636828722E7375626D6974436C6F6246726F6D297B636173';
wwv_flow_api.g_varchar2_table(12) := '6522706167656974656D223A6F3D6974656D28722E7375626D6974436C6F624974656D292E67657456616C756528293B627265616B3B63617365226A6176617363726970747661726961626C65223A766172206C3D77696E646F775B722E7375626D6974';
wwv_flow_api.g_varchar2_table(13) := '436C6F625661726961626C655D3B6F3D6C20696E7374616E63656F66204F626A6563743F4A534F4E2E737472696E67696679286C293A6C7D617065782E7365727665722E706C7567696E28692C7B706167654974656D733A742E6974656D73546F537562';
wwv_flow_api.g_varchar2_table(14) := '6D69742C705F636C6F625F30313A6F7D2C7B64617461547970653A226A736F6E222C6C6F6164696E67496E64696361746F723A742E6974656D73546F52657475726E2E6D617028653D3E2223222B65292E6A6F696E28222C22292C7461726765743A652E';
wwv_flow_api.g_varchar2_table(15) := '62726F777365724576656E742E7461726765747D292E646F6E65282866756E6374696F6E2865297B2166756E6374696F6E2865297B6966282273756363657373223D3D652E737461747573297B76617220732C693B696628652626652E6974656D73297B';
wwv_flow_api.g_varchar2_table(16) := '733D652E6974656D732E6C656E6774682C693D652E6974656D733B666F722876617220743D303B743C733B742B2B29247328695B745D2E69642C695B745D2E76616C75652C6E756C6C2C6E2E73757070726573734368616E67654576656E74297D696628';
wwv_flow_api.g_varchar2_table(17) := '722E72657475726E436C6F622973776974636828722E72657475726E436C6F62496E746F297B6361736522706167656974656D223A247328722E72657475726E436C6F624974656D2C652E636C6F622C6E756C6C2C6E2E73757070726573734368616E67';
wwv_flow_api.g_varchar2_table(18) := '654576656E74293B627265616B3B63617365226A6176617363726970747661726961626C65223A464F532E65786563506C53716C2E6372656174654E65737465644F626A656374416E6441737369676E2877696E646F772C722E72657475726E436C6F62';
wwv_flow_api.g_varchar2_table(19) := '5661726961626C652C652E636C6F62293B627265616B3B63617365226A6176617363726970747661726961626C656A736F6E223A464F532E65786563506C53716C2E6372656174654E65737465644F626A656374416E6441737369676E2877696E646F77';
wwv_flow_api.g_varchar2_table(20) := '2C722E72657475726E436C6F625661726961626C652C4A534F4E2E706172736528652E636C6F6229297D652E6D6573736167652626617065782E6D6573736167652E73686F77506167655375636365737328652E6D657373616765292C617065782E6461';
wwv_flow_api.g_varchar2_table(21) := '2E726573756D6528612C2131297D656C7365226572726F72223D3D652E7374617475732626652E6D6573736167652626286E2E73686F774572726F724173416C6572743F617065782E6D6573736167652E616C65727428652E6D657373616765293A2861';
wwv_flow_api.g_varchar2_table(22) := '7065782E6D6573736167652E636C6561724572726F727328292C617065782E6D6573736167652E73686F774572726F7273287B747970653A226572726F72222C6C6F636174696F6E3A2270616765222C6D6573736167653A652E6D6573736167652C756E';
wwv_flow_api.g_varchar2_table(23) := '736166653A21317D2929297D2865297D29292E6661696C282866756E6374696F6E28652C732C69297B617065782E64612E68616E646C65416A61784572726F727328652C732C692C61297D29292E616C77617973282866756E6374696F6E28297B7D2929';
wwv_flow_api.g_varchar2_table(24) := '7D3B0A2F2F2320736F757263654D617070696E6755524C3D7363726970742E6A732E6D6170';
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
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C22736F7572636573223A5B227363726970742E6A73225D2C226E616D6573223A5B2277696E646F77222C22464F53222C2265786563506C53716C222C2273686F775370696E6E6572222C22636F6E666967222C22617065';
wwv_flow_api.g_varchar2_table(2) := '78222C226465627567222C22696E666F222C226C5370696E6E6572222C226C57616974506F70757024222C2273656C6563746F72222C22646973706C61794F7665726C6179222C2224222C2270726570656E64546F222C227574696C222C226669786564';
wwv_flow_api.g_varchar2_table(3) := '222C227370696E6E6572436C617373222C2272656D6F7665222C22756E646566696E6564222C226372656174654E65737465644F626A656374416E6441737369676E222C226F626A222C226B657950617468222C2276616C7565222C2273706C6974222C';
wwv_flow_api.g_varchar2_table(4) := '226C6173744B6579496E646578222C226C656E677468222C2269222C226B6579222C2265786563757465506C53716C436F6465222C226461436F6E74657874222C22616374696F6E222C22726573756D6543616C6C6261636B222C22616A61784964222C';
wwv_flow_api.g_varchar2_table(5) := '22706167654974656D73222C22636C6F6253657474696E6773222C226F7074696F6E73222C22636C6F62546F5375626D6974222C2244617465222C2267657454696D65222C227375626D6974436C6F62222C227375626D6974436C6F6246726F6D222C22';
wwv_flow_api.g_varchar2_table(6) := '6974656D222C227375626D6974436C6F624974656D222C2267657456616C7565222C22746F5375626D6974222C227375626D6974436C6F625661726961626C65222C224F626A656374222C224A534F4E222C22737472696E67696679222C227365727665';
wwv_flow_api.g_varchar2_table(7) := '72222C22706C7567696E222C226974656D73546F5375626D6974222C22705F636C6F625F3031222C226461746154797065222C226C6F6164696E67496E64696361746F72222C226974656D73546F52657475726E222C226D6170222C226A6F696E222C22';
wwv_flow_api.g_varchar2_table(8) := '746172676574222C2262726F777365724576656E74222C22646F6E65222C2264617461222C227044617461222C22737461747573222C226974656D436F756E74222C226974656D4172726179222C226974656D73222C222473222C226964222C22737570';
wwv_flow_api.g_varchar2_table(9) := '70726573734368616E67654576656E74222C2272657475726E436C6F62222C2272657475726E436C6F62496E746F222C2272657475726E436C6F624974656D222C22636C6F62222C2272657475726E436C6F625661726961626C65222C22706172736522';
wwv_flow_api.g_varchar2_table(10) := '2C226D657373616765222C2273686F775061676553756363657373222C226461222C22726573756D65222C2273686F774572726F724173416C657274222C22616C657274222C22636C6561724572726F7273222C2273686F774572726F7273222C227479';
wwv_flow_api.g_varchar2_table(11) := '7065222C226C6F636174696F6E222C22756E73616665222C225F68616E646C65526573706F6E7365222C226661696C222C226A71584852222C2274657874537461747573222C226572726F725468726F776E222C2268616E646C65416A61784572726F72';
wwv_flow_api.g_varchar2_table(12) := '73222C22616C77617973225D2C226D617070696E6773223A2241414141412C4F41414F432C49414153442C4F41414F432C4B4141552C4741436A43412C49414149432C55414159442C49414149432C574141612C4741456A43442C49414149432C554141';
wwv_flow_api.g_varchar2_table(13) := '55432C594141632C53414155432C4741456C43432C4B41414B432C4D41414D432C4B41414B2C344241413642482C47414537432C49414749492C45414341432C45414A41432C454141574E2C4541414F4D2C53414D74422C47414C71424E2C4541414F4F';
wwv_flow_api.g_varchar2_table(14) := '2C65414B522C4341496842462C45414163472C454141452C6742414138422C5141415A462C4541486C422C32484143452C3448414567452C59414159472C55414155442C45414145462C49414B39472C4F414641462C45414157482C4B41414B532C4B41';
wwv_flow_api.g_varchar2_table(15) := '414B582C594141594F2C45414175422C5141415A412C45414171422C434141454B2C4F41414F2C474141532C43414145432C614141632C6B43414535462C43414348432C4F4141512C674241436742432C4941416842542C47414341412C45414159512C';
wwv_flow_api.g_varchar2_table(16) := '63414543432C49414162562C47414341412C45414153532C59414F7A4268422C49414149432C5541415569422C3442414138422C53414155432C4541414B432C45414153432C4741436845442C45414155412C45414151452C4D41414D2C4B4143784243';
wwv_flow_api.g_varchar2_table(17) := '2C61414165482C45414151492C4F4141532C45414368432C4941414B2C49414149432C454141492C45414147412C45414149462C6541416742452C4541436843432C4941414D4E2C454141514B2C47414352432C4F41414F502C49414354412C45414149';
wwv_flow_api.g_varchar2_table(18) := '4F2C4B41414F2C49414566502C4541414D412C454141494F2C4B414564502C45414149432C45414151472C6541416942462C4741476A4372422C49414149432C5541415530422C694241416D422C53414155432C454141577A422C4741436C44432C4B41';
wwv_flow_api.g_varchar2_table(19) := '414B432C4D41414D432C4B41414B2C364241413842482C4741456A4379422C45414155432C4F414176422C49414349432C4541416942462C45414155452C6541433342432C4541415335422C4541414F34422C4F41436842432C4541415937422C454141';
wwv_flow_api.g_varchar2_table(20) := '4F36422C5541456E42432C4541416539422C4541414F38422C6141437442432C454141552F422C4541414F2B422C5141344472422C4941794249432C47417A42572C49414149432C4D41414F432C5541324231422C474141494A2C454141614B2C574143';
wwv_flow_api.g_varchar2_table(21) := '622C4F4141514C2C454141614D2C674241436A422C4941414B2C574143444A2C454141654B2C4B41414B502C45414161512C674241416742432C5741436A442C4D41434A2C4941414B2C71424143442C49414149432C4541415735432C4F41414F6B432C';
wwv_flow_api.g_varchar2_table(22) := '45414161572C6F4241472F42542C45414441512C6141416F42452C4F41434C432C4B41414B432C554141554A2C47414566412C4541516C4276432C4B41414B34432C4F41414F432C4F41414F6C422C454141512C4341437043432C55414157412C454141';
wwv_flow_api.g_varchar2_table(23) := '556B422C6341437242432C5541415768422C4741435A2C4341434369422C534141552C4F414356432C694241416B4272422C4541415573422C63414163432C49414149662C474141512C4941414D412C4741414D67422C4B41414B2C4B41437645432C4F';
wwv_flow_api.g_varchar2_table(24) := '41415137422C4541415538422C61414161442C5341473542452C4D41414B2C53414153432C49416A4872422C5341417942432C47414372422C4741416F422C5741416842412C4541414D432C4F414171422C43414333422C49414149432C45414157432C';
wwv_flow_api.g_varchar2_table(25) := '454145662C47414149482C47414153412C4541414D492C4D41414F2C4341437442462C45414159462C4541414D492C4D41414D7A432C4F4143784277432C45414159482C4541414D492C4D41436C422C4941414B2C4941414978432C454141492C454141';
wwv_flow_api.g_varchar2_table(26) := '47412C4541414973432C4541415774432C494143334279432C47414147462C4541415576432C4741414730432C47414149482C4541415576432C474141474A2C4D41414F2C4B41414D612C454141516B432C7142414B39442C474141496E432C45414161';
wwv_flow_api.g_varchar2_table(27) := '6F432C574143622C4F41415170432C4541416171432C674241436A422C4941414B2C574143444A2C474141476A432C4541416173432C6541416742562C4541414D572C4B41414D2C4B41414D74432C454141516B432C7142414331442C4D41434A2C4941';
wwv_flow_api.g_varchar2_table(28) := '414B2C714241434470452C49414149432C5541415569422C3442414134426E422C4F4141516B432C4541416177432C6D4241416F425A2C4541414D572C4D41437A462C4D41434A2C4941414B2C794241434478452C49414149432C5541415569422C3442';
wwv_flow_api.g_varchar2_table(29) := '414134426E422C4F4141516B432C4541416177432C6D4241416F4233422C4B41414B34422C4D41414D622C4541414D572C4F414F3547582C4541414D632C5341434E76452C4B41414B75452C51414151432C674241416742662C4541414D632C53414B76';
wwv_flow_api.g_varchar2_table(30) := '4376452C4B41414B79452C47414147432C4F41414F68442C47414167422C4F4143522C53414168422B422C4541414D432C51414354442C4541414D632C554145467A432C4541415136432C694241435233452C4B41414B75452C514141514B2C4D41414D';
wwv_flow_api.g_varchar2_table(31) := '6E422C4541414D632C5541477A4276452C4B41414B75452C514141514D2C6341476237452C4B41414B75452C514141514F2C574141572C4341437042432C4B41414D2C5141434E432C534141552C4F414356542C51414153642C4541414D632C51414366';
wwv_flow_api.g_varchar2_table(32) := '552C514141512C4D4167457842432C434141674231422C4D41436A4232422C4D41414B2C53414153432C4541414F432C45414159432C474143684374462C4B41414B79452C47414147632C694241416942482C4541414F432C45414159432C4541416135';
wwv_flow_api.g_varchar2_table(33) := '442C4D4143314438442C5141414F222C2266696C65223A227363726970742E6A73227D';
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
prompt --application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done


