class ZCL_ODATA_FIELD_JOB_DPC_EXT definition
  public
  inheriting from ZCL_ODATA_FIELD_JOB_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITYSET
    redefinition .
protected section.

  methods JOBHEADERSET_GET_ENTITYSET
    redefinition .
  methods JOBLOGSET_GET_ENTITY
    redefinition .
  methods JOBLOGSET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ODATA_FIELD_JOB_DPC_EXT IMPLEMENTATION.


METHOD /iwbep/if_mgw_appl_srv_runtime~get_entityset.

  DATA: lt_jobs_hdr  TYPE TABLE OF zjobs_hdr,
        ls_jobs_hdr  TYPE zjobs_hdr,
        lt_entityset TYPE zcl_odata_field_job_mpc_ext=>tt_jobheader,
        ls_entity    TYPE zcl_odata_field_job_mpc_ext=>ts_jobheader.

  " Select only open jobs
  SELECT * FROM zjobs_hdr
    INTO TABLE lt_jobs_hdr
    UP TO 10 ROWS
    WHERE status = 'Open'.

  LOOP AT lt_jobs_hdr INTO ls_jobs_hdr.
    MOVE-CORRESPONDING ls_jobs_hdr TO ls_entity.
    APPEND ls_entity TO lt_entityset.
  ENDLOOP.

  copy_data_to_ref(
    EXPORTING
      is_data = lt_entityset
    CHANGING
      cr_data = er_entityset ).


ENDMETHOD.


METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entityset.
*  DATA: lv_entityset   TYPE string,
*        lt_jobheaders  TYPE TABLE OF zjobs_log,
*        ls_jobheader   TYPE zjobs_log,
*        lt_response    TYPE zcl_odata_field_job_mpc_ext=>tt_joblog.
*
*  CONSTANTS: lc_nav_to_log TYPE string VALUE 'JobLogSet'.
*
*  IF io_tech_request_context IS NOT BOUND.
*    RETURN.
*  ENDIF.
*
*  io_tech_request_context->get_entity_set_name(
*    RECEIVING rv_entity_set = lv_entityset
*  ).
*
**  IF lv_entityset = 'JobHeaderSet'.
**    SELECT * FROM zjobs_hdr INTO TABLE lt_jobheaders.
*
**
*
**    LOOP AT lt_jobheaders INTO ls_jobheader.
**      DATA(ls_response) = CORRESPONDING zcl_odata_field_job_mpc_ext=>ts_jobheader( ls_jobheader ).
**
**      APPEND ls_response TO lt_response.
**    ENDLOOP.
*
*IF lv_entityset = 'JobLogSet'.
*  SELECT * FROM zjobs_log INTO TABLE lt_jobheaders.
*
*
*    LOOP AT lt_jobheaders INTO ls_jobheader.
*      DATA(ls_response) = CORRESPONDING zcl_odata_field_job_mpc_ext=>ts_joblog( ls_jobheader ).
**
*      APPEND ls_response TO lt_response.
*    ENDLOOP.
*
*    copy_data_to_ref(
*      EXPORTING
*        is_data = lt_response
*      CHANGING
*        cr_data = er_entityset
*    ).
*
*    APPEND lc_nav_to_log TO et_expanded_tech_clauses.
*  ENDIF.



*  METHOD jobheaderset_get_expanded_entityset.

  DATA: lv_entityset   TYPE string,
        lt_jobheaders  TYPE TABLE OF zjobs_hdr,
        ls_jobheader   TYPE zjobs_hdr,
        lt_joblogs     TYPE TABLE OF zjobs_log,
        lt_response    TYPE zcl_odata_field_job_mpc_ext=>tt_jobheader,
        ls_response    TYPE zcl_odata_field_job_mpc_ext=>ts_jobheader,
        lt_log_entities TYPE zcl_odata_field_job_mpc_ext=>tt_joblog,
        ls_log_entity   TYPE zcl_odata_field_job_mpc_ext=>ts_joblog.

  CONSTANTS: lc_nav_to_log TYPE string VALUE 'JobLogSet'.

  IF io_tech_request_context IS NOT BOUND.
    RETURN.
  ENDIF.

  " Get requested entity set name
  io_tech_request_context->get_entity_set_name(
    RECEIVING rv_entity_set = lv_entityset
  ).

  IF lv_entityset = 'JobHeaderSet'.

    " Read headers
    SELECT * FROM zjobs_hdr INTO TABLE lt_jobheaders.

    LOOP AT lt_jobheaders INTO ls_jobheader.

      CLEAR: ls_response, lt_log_entities.

      " Move header fields
      MOVE-CORRESPONDING ls_jobheader TO ls_response.

      " Get associated items (logs) for each header
      SELECT * FROM zjobs_log INTO TABLE lt_joblogs
        WHERE job_id = ls_jobheader-job_id.

      LOOP AT lt_joblogs INTO DATA(ls_joblog).
        CLEAR ls_log_entity.
        MOVE-CORRESPONDING ls_joblog TO ls_log_entity.
        APPEND ls_log_entity TO lt_log_entities.
      ENDLOOP.

*       Attach logs to header response using navigation property
      ls_response-job_id = ls_log_entity-job_id.

*      APPEND ls_response TO lt_response.

APPEND ls_log_entity TO lt_log_entities.

    ENDLOOP.

    " Return data
    copy_data_to_ref(
      EXPORTING
        is_data = lt_log_entities
      CHANGING
        cr_data = er_entityset
    ).


    " Let framework know expanded entity is included
    APPEND lc_nav_to_log TO et_expanded_tech_clauses.

  ENDIF.


*ENDMETHOD.
ENDMETHOD.


  method JOBHEADERSET_GET_ENTITYSET.
*
*  DATA: lt_jobs_hdr  TYPE TABLE OF zjobs_hdr,
*          ls_jobs_hdr  TYPE zjobs_hdr,
*          lt_entityset TYPE zcl_odata_field_job_mpc_ext=>tt_jobheader.
*
*    " Select only open jobs
*    SELECT job_id
*           equip_id
*           status
*           fault_code
*          priority
*          assigned_to
*          job_date
*          created_by
*          created_on
*      FROM zjobs_hdr
*      INTO TABLE lt_entityset UP TO 10 ROWS
*      WHERE status = 'Open' .
*    IF sy-subrc = 0.
*      move lt_entityset to et_entityset.
*    ENDIF.


*DATA: lt_jobs_hdr  TYPE TABLE OF zjobs_hdr,
*        ls_jobs_hdr  TYPE zjobs_hdr,
*        lt_entityset TYPE zcl_odata_field_job_mpc_ext=>tt_jobheader,
*        ls_entity    TYPE zcl_odata_field_job_mpc_ext=>ts_jobheader.
*
*  " Select only open jobs
*  SELECT * FROM zjobs_hdr
*    INTO TABLE lt_jobs_hdr
*    UP TO 10 ROWS
*    WHERE status = 'Open'.
*
**  LOOP AT lt_jobs_hdr INTO ls_jobs_hdr.
**    MOVE-CORRESPONDING ls_jobs_hdr TO ls_entity.
**    APPEND ls_entity TO lt_entityset.
***    clear ls_entity.
**  ENDLOOP.
*move lt_jobs_hdr to et_entityset.
*  copy_data_to_ref(
*    EXPORTING
*      is_data = lt_entityset
*    CHANGING
*      cr_data = et_entityset ).
  endmethod.


  method JOBLOGSET_GET_ENTITY.
**TRY.
*CALL METHOD SUPER->JOBLOGSET_GET_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_request_object       =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**  IMPORTING
**    er_entity               =
**    es_response_context     =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
  endmethod.


METHOD /iwbep/if_mgw_appl_srv_runtime~get_entity.
  DATA:
    lv_entityset TYPE string,
    lt_key_tab   TYPE /iwbep/t_mgw_name_value_pair,
    ls_key       TYPE /iwbep/s_mgw_name_value_pair,
    lv_job_id    TYPE zjobs_hdr-job_id,
    lv_log_seq   TYPE zjobs_log-log_seq,
    ls_job_log   TYPE zjobs_log,
    ls_response  TYPE zcl_odata_field_job_mpc_ext=>ts_joblog.

  " Corrected method call with proper parentheses
  io_tech_request_context->get_entity_set_name(
    RECEIVING
      rv_entity_set = lv_entityset
  ).

  " Rest of your implementation
  lt_key_tab = it_key_tab.

  IF lv_entityset = 'JobLogSet'.
    LOOP AT lt_key_tab INTO ls_key.
      CASE ls_key-name.
        WHEN 'Job_ID'.
          lv_job_id = ls_key-value.
        WHEN 'Log_Seq'.
          lv_log_seq = CONV #( ls_key-value ).
      ENDCASE.
    ENDLOOP.

    SELECT SINGLE * FROM zjobs_log INTO ls_job_log
     WHERE job_id = lv_job_id
       AND log_seq = lv_log_seq.

    IF sy-subrc = 0.
      ls_response-job_id         = ls_job_log-job_id.
      ls_response-log_seq        = ls_job_log-log_seq.
      ls_response-action_taken   = ls_job_log-action_taken.
      ls_response-time_spent_hrs = ls_job_log-time_spent_hrs.
      ls_response-technician_note = ls_job_log-technician_note.
      ls_response-created_by     = ls_job_log-created_by.
      ls_response-created_on     = ls_job_log-created_on.
    ELSE.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = /iwbep/cx_mgw_busi_exception=>entity_not_found
          message = |No log found for Job { lv_job_id } Seq { lv_log_seq }|.
    ENDIF.

    copy_data_to_ref(
      EXPORTING is_data = ls_response
      CHANGING cr_data = er_entity
    ).
  ENDIF.
ENDMETHOD.


  method JOBLOGSET_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->JOBLOGSET_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
  endmethod.
ENDCLASS.
