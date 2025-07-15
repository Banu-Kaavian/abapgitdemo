class ZCL_ODATA_SPARE_LOOKU_DPC_EXT definition
  public
  inheriting from ZCL_ODATA_SPARE_LOOKU_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_ENTITY
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ODATA_SPARE_LOOKU_DPC_EXT IMPLEMENTATION.


METHOD /iwbep/if_mgw_appl_srv_runtime~create_entity.
**TRY.
*CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_ENTITY
*  EXPORTING
**    iv_entity_name          =
**    iv_entity_set_name      =
**    iv_source_name          =
*    IO_DATA_PROVIDER        =
**    it_key_tab              =
**    it_navigation_path      =
**    io_tech_request_context =
**  IMPORTING
**    er_entity               =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.

  DATA: ls_input TYPE ZCL_ZODATA_SPARE_LOOKU_MPC_EXT=>ts_spare.
  io_data_provider->read_entry_data( IMPORTING es_data = ls_input ).



  CALL FUNCTION 'ZSPARE_UPLOAD'
    EXPORTING
      spare_id       = ls_input-spare_id
      equip_id       = ls_input-equip_id
      spare_name     = ls_input-spare_name
      last_used_date = ls_input-last_used_date
      stock_qty      = ls_input-stock_qty.
            .
 copy_data_to_ref(
          EXPORTING
            is_data = ls_input
            CHANGING
              cr_data = er_entity ).
*  es_entity = ls_input.
ENDMETHOD.  "/iwbep/if_mgw_appl_srv_runtime~create_entity


METHOD /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET.
  DATA: lt_spares TYPE STANDARD TABLE OF zjobs_spares.

  TRY.
      " Get all spare parts data from the database table
      SELECT * FROM zjobs_spares INTO TABLE @lt_spares.

      " Copy data to output
      copy_data_to_ref(
        EXPORTING
          is_data = lt_spares
        CHANGING
          cr_data = er_entityset
      ).

    CATCH cx_root INTO DATA(lx_root).
      " Log the full error (optional)
      DATA(lv_error) = lx_root->get_text( ).

      " Raise proper OData exception
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
        EXPORTING
          textid            = /iwbep/cx_mgw_tech_exception=>internal_error
          previous          = lx_root
          http_status_code  = 500.  " Internal server error
  ENDTRY.
ENDMETHOD.
ENDCLASS.
