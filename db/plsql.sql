function render
    ( p_dynamic_action apex_plugin.t_dynamic_action
    , p_plugin         apex_plugin.t_plugin
    )
return apex_plugin.t_dynamic_action_render_result
is
    l_result apex_plugin.t_dynamic_action_render_result;

    l_ajax_id varchar(4000) := apex_plugin.get_ajax_identifier;

    l_items_to_submit apex_t_varchar2 := apex_string.split(p_dynamic_action.attribute_02, ',');
    l_items_to_return apex_t_varchar2 := apex_string.split(p_dynamic_action.attribute_03, ',');

    l_submit_clob           p_dynamic_action.attribute_06%type := p_dynamic_action.attribute_06;
    l_submit_clob_item      p_dynamic_action.attribute_07%type := p_dynamic_action.attribute_07;
    l_submit_clob_variable  p_dynamic_action.attribute_08%type := p_dynamic_action.attribute_08;

    l_return_clob           p_dynamic_action.attribute_09%type := p_dynamic_action.attribute_09;
    l_return_clob_item      p_dynamic_action.attribute_10%type := p_dynamic_action.attribute_10;
    l_return_clob_variable  p_dynamic_action.attribute_11%type := p_dynamic_action.attribute_11;

    --extra options
    l_suppress_change_event boolean := instr(p_dynamic_action.attribute_15, 'suppressChangeEvent') > 0;
    l_show_error_as_alert   boolean := instr(p_dynamic_action.attribute_15, 'showErrorAsAlert')    > 0;

begin

    if apex_application.g_debug then
        apex_plugin_util.debug_dynamic_action
            ( p_plugin         => p_plugin
            , p_dynamic_action => p_dynamic_action
            );
    end if;

    apex_json.initialize_clob_output;
    apex_json.open_object;

    apex_json.write('ajaxId',  l_ajax_id);

    apex_json.open_object('pageItems');
    apex_json.write('itemsToSubmit', l_items_to_submit);
    apex_json.write('itemsToReturn', l_items_to_return);
    apex_json.close_object;


    apex_json.open_object('clobSettings');
    apex_json.write('submitClob', l_submit_clob is not null);
    apex_json.write('submitClobFrom', l_submit_clob);
    apex_json.write('submitClobItem', l_submit_clob_item);
    apex_json.write('submitClobVariable', l_submit_clob_variable);
    apex_json.write('returnClob', l_return_clob is not null);
    apex_json.write('returnClobInto', l_return_clob);
    apex_json.write('returnClobItem', l_return_clob_item);
    apex_json.write('returnClobVariable', l_return_clob_variable);
    apex_json.close_object;

    apex_json.open_object('options');
    apex_json.write('suppressChangeEvent', l_suppress_change_event);
    apex_json.write('showErrorAsAlert', l_show_error_as_alert);
    apex_json.close_object;

    apex_json.close_object;
    l_result.javascript_function := 'function(){FOS.execPlSql.executePlSqlCode(this, '|| apex_json.get_clob_output ||');}';

    apex_json.free_output;
    return l_result;
end;

function ajax
    ( p_dynamic_action apex_plugin.t_dynamic_action
    , p_plugin         apex_plugin.t_plugin
    )
return apex_plugin.t_dynamic_action_ajax_result
is
    l_result           apex_plugin.t_dynamic_action_ajax_result;

    l_statement        p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;
    l_items_to_return  p_dynamic_action.attribute_03%type := p_dynamic_action.attribute_03;
    l_success_message  p_dynamic_action.attribute_04%type := p_dynamic_action.attribute_04;
    l_error_message    p_dynamic_action.attribute_05%type := p_dynamic_action.attribute_05;
    l_return_clob      boolean                            := p_dynamic_action.attribute_09 is not null;

    l_message          varchar2(4000);
    l_item_names       apex_t_varchar2;
begin

    if apex_application.g_debug then
        apex_plugin_util.debug_dynamic_action
            ( p_plugin         => p_plugin
            , p_dynamic_action => p_dynamic_action
            );
    end if;

    apex_exec.execute_plsql(p_plsql_code => l_statement);

    apex_json.initialize_output;
    apex_json.open_object;

    if l_items_to_return is not null then
        l_item_names := apex_string.split(l_items_to_return, ',');

        apex_json.open_array('items');

        for i in 1 .. l_item_names.count loop
            apex_json.open_object;
            apex_json.write('id', apex_plugin_util.item_names_to_dom
                ( p_item_names     => l_item_names(i)
                , p_dynamic_action => p_dynamic_action
                )
            );
            apex_json.write('value', V(l_item_names(i)));
            apex_json.close_object;
        end loop;

        apex_json.close_array;
    end if;

    if l_return_clob then
        apex_json.write('clob', apex_application.g_clob_01);
    end if;

    apex_json.write('status', 'success');

    l_message := nvl(apex_application.g_x01, l_success_message);
    apex_json.write('message', l_message);

    apex_json.close_object;

    return l_result;

exception
    when others then
        rollback;

        apex_json.initialize_output;
        apex_json.open_object;
        apex_json.write('status', 'error');

        l_message := nvl(apex_application.g_x02, l_error_message);

        l_message := replace(l_message, '#SQLCODE#', apex_escape.html(sqlcode));
        l_message := replace(l_message, '#SQLERRM#', apex_escape.html(sqlerrm));
        l_message := replace(l_message, '#SQLERRM_TEXT#', apex_escape.html(substr(sqlerrm, instr(sqlerrm, ':')+1)));

        apex_json.write('message', l_message);

        apex_json.close_object;

        return l_result;
end;


