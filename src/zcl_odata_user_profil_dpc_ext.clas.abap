class ZCL_ODATA_USER_PROFIL_DPC_EXT definition
  public
  inheriting from ZCL_ODATA_USER_PROFIL_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ODATA_USER_PROFIL_DPC_EXT IMPLEMENTATION.


METHOD /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET.
  DATA: lt_users TYPE STANDARD TABLE OF zuser_profile.

  TRY.
      " Get all user profiles from database
      SELECT * FROM zuser_profile INTO TABLE @lt_users.

      " Copy data to output
      copy_data_to_ref(
        EXPORTING
          is_data = lt_users
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
