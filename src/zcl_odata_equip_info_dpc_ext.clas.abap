class ZCL_ODATA_EQUIP_INFO_DPC_EXT definition
  public
  inheriting from ZCL_ODATA_EQUIP_INFO_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITY
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ODATA_EQUIP_INFO_DPC_EXT IMPLEMENTATION.


METHOD /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITY.
  DATA: ls_equipment TYPE zequip_master,
        lv_equip_id  TYPE zequip_master-equip_id.

  TRY.
      " 1. Get the Equipment ID from the key tab
      READ TABLE it_key_tab WITH KEY name = 'Equip_Id' INTO DATA(ls_key).
      IF sy-subrc = 0.
        lv_equip_id = ls_key-value.
      ELSE.
        " Key not found - raise business exception
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid  = /iwbep/cx_mgw_busi_exception=>business_error
            message = 'Equipment ID not provided'.
      ENDIF.

      " 2. Fetch single record from database
      SELECT SINGLE * FROM zequip_master INTO ls_equipment
        WHERE equip_id = lv_equip_id.
      IF sy-subrc <> 0.
        " Record not found - raise business exception
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid  = /iwbep/cx_mgw_busi_exception=>business_error
            message = 'Equipment not found'.
      ENDIF.

      " 3. Convert dates if needed (optional)
      " Example if you need to convert ABAP date to OData format:
      " ls_equipment-commissioned_date = convert_to_odata_date( ls_equipment-commissioned_date ).

      " 4. Return the data using copy_data_to_ref
      copy_data_to_ref(
        EXPORTING
          is_data = ls_equipment
        CHANGING
          cr_data = er_entity
      ).

    CATCH /iwbep/cx_mgw_busi_exception INTO DATA(lx_busi).
      RAISE EXCEPTION lx_busi.

    CATCH /iwbep/cx_mgw_tech_exception INTO DATA(lx_tech).
      RAISE EXCEPTION lx_tech.

    CATCH cx_root INTO DATA(lx_root).
      " Catch any other exceptions
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
        EXPORTING
          textid = /iwbep/cx_mgw_tech_exception=>internal_error
          previous = lx_root.
  ENDTRY.
ENDMETHOD.


METHOD /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET.
  DATA: lt_equipments TYPE STANDARD TABLE OF zequip_master.

  TRY.
      " Get data from database
      SELECT * FROM zequip_master INTO TABLE lt_equipments.

      " Copy data to output
      copy_data_to_ref(
        EXPORTING
          is_data = lt_equipments
        CHANGING
          cr_data = er_entityset
      ).

    CATCH cx_root INTO DATA(lx_root).
      " Log the full error (optional)
      DATA(lv_error) = lx_root->get_text( ).

      " Raise proper OData exception - CORRECTED VERSION
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
        EXPORTING
          textid            = /iwbep/cx_mgw_tech_exception=>internal_error
          previous          = lx_root
          http_status_code = 500.  " Internal server error
  ENDTRY.
ENDMETHOD.
ENDCLASS.
