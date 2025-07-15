CLASS zcl_insert_equip_master DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_equip_master,
        equip_id            TYPE zequip_master-equip_id,
        description         TYPE zequip_master-description,
        location            TYPE zequip_master-location,
        equip_type          TYPE zequip_master-equip_type,
        commissioned_date   TYPE zequip_master-commissioned_date,
        warranty_expiry     TYPE zequip_master-warranty_expiry,
      END OF ty_equip_master.

    TYPES tt_equip_master TYPE STANDARD TABLE OF ty_equip_master WITH EMPTY KEY.

    DATA mt_equip_master TYPE tt_equip_master.

    METHODS: load_data,
             insert_data.

ENDCLASS.

CLASS zcl_insert_equip_master IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    TRY.
        " Step 1: Load Data
        me->load_data( ).
        cl_demo_output=>write( 'Data Loaded Successfully.' ).

        " Step 2: Insert Data into DB
        me->insert_data( ).

        " Display the final output
        cl_demo_output=>display( ).

      CATCH cx_root INTO DATA(lx_error).
        cl_demo_output=>write( 'Error: ' && lx_error->get_text( ) ).
        cl_demo_output=>display( ).
    ENDTRY.
  ENDMETHOD.

  METHOD load_data.
    " Populate hardcoded data
    mt_equip_master = VALUE tt_equip_master(
      ( equip_id = 'P-2700' description = 'Centrifugal Pump Model 0' location = 'Plant 1'
        equip_type = 'Pump' commissioned_date = '20180101' warranty_expiry = '20251231' )

      ( equip_id = 'P-2701' description = 'Centrifugal Pump Model 1' location = 'Plant 2'
        equip_type = 'Pump' commissioned_date = '20180201' warranty_expiry = '20251231' )

      ( equip_id = 'P-2702' description = 'Centrifugal Pump Model 2' location = 'Plant 3'
        equip_type = 'Pump' commissioned_date = '20180301' warranty_expiry = '20251231' )

      ( equip_id = 'P-2703' description = 'Centrifugal Pump Model 3' location = 'Plant 1'
        equip_type = 'Pump' commissioned_date = '20180401' warranty_expiry = '20251231' )

      ( equip_id = 'P-2704' description = 'Centrifugal Pump Model 4' location = 'Plant 2'
        equip_type = 'Pump' commissioned_date = '20180501' warranty_expiry = '20251231' )
    ).
  ENDMETHOD.

  METHOD insert_data.
    " Insert into DB
    INSERT zequip_master FROM TABLE @mt_equip_master.
    IF sy-subrc = 0.
      cl_demo_output=>write( |Successfully inserted { lines( mt_equip_master ) } records into ZEQUIP_MASTER.| ).
      COMMIT WORK.
    ELSE.
      cl_demo_output=>write( 'Data Insertion Failed.' ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.

