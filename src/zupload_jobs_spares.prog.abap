*REPORT zupload_jobs_spares.
*
*TABLES zjobs_spares.
*
*TYPES: BEGIN OF ty_jobs_spares,
*         spare_id       TYPE zjobs_spares-spare_id,
*         equip_id       TYPE zjobs_spares-equip_id,
*         spare_name     TYPE zjobs_spares-spare_name,
*         last_used_date TYPE zjobs_spares-last_used_date,
*         stock_qty      TYPE zjobs_spares-stock_qty,
*       END OF ty_jobs_spares.
*
*DATA: lt_spares  TYPE TABLE OF ty_jobs_spares,
*      lv_file    TYPE string,
*      lt_raw     TYPE STANDARD TABLE OF string,
*      lv_line    TYPE string,
*      lt_files   TYPE filetable,
*      lv_rc      TYPE i,
*      lv_length  TYPE i.
*
*START-OF-SELECTION.
*
*  " File open dialog for CSV selection
*  cl_gui_frontend_services=>file_open_dialog(
*    EXPORTING
*      file_filter = 'CSV Files (*.csv)|*.csv|'
*    CHANGING
*      file_table  = lt_files
*      rc          = lv_rc
*    EXCEPTIONS
*      OTHERS      = 1 ).
*
*  IF lv_rc <= 0 OR lines( lt_files ) = 0.
*    WRITE: / 'No file selected or operation cancelled.'.
*    RETURN.
*  ENDIF.
*
*  " Get filename from selected file
*  READ TABLE lt_files INDEX 1 INTO lv_file.
*  IF sy-subrc <> 0.
*    WRITE: / 'File not found!'.
*    RETURN.
*  ENDIF.
*
*  " Upload CSV file content
*  cl_gui_frontend_services=>gui_upload(
*    EXPORTING
*      filename            = lv_file
*      filetype            = 'ASC'
*      has_field_separator = abap_true
*    IMPORTING
*      filelength          = lv_length
*    CHANGING
*      data_tab            = lt_raw
*    EXCEPTIONS
*      OTHERS              = 1 ).
*
*  IF sy-subrc <> 0.
*    WRITE: / 'Error uploading file.'.
*    RETURN.
*  ENDIF.
*
*  " Loop over CSV lines starting from 2 to skip header
*  LOOP AT lt_raw INTO lv_line FROM 2.
*
*    DATA(ls_spare) = VALUE ty_jobs_spares( ).
*    DATA(lv_date)  = VALUE string( ).
*    DATA(lv_qty)   = VALUE string( ).
*
*    " Split CSV line by comma into fields
*    SPLIT lv_line AT ',' INTO
*      ls_spare-spare_id
*      ls_spare-equip_id
*      ls_spare-spare_name
*      lv_date
*      lv_qty.
*
*    " Convert date (remove '-' if present)
*    REPLACE ALL OCCURRENCES OF '-' IN lv_date WITH ''.
*    ls_spare-last_used_date = lv_date.
*
*    " Convert quantity to integer
*    TRY.
*        ls_spare-stock_qty = lv_qty.
*      CATCH cx_sy_conversion_no_number.
*        WRITE: / 'Invalid stock_qty in line: ', lv_line.
*        CONTINUE.
*    ENDTRY.
*
*    " Append to internal table
*    APPEND ls_spare TO lt_spares.
*
*  ENDLOOP.
*
*  " Insert all records into ZJOBS_SPARES
*  INSERT zjobs_spares FROM TABLE lt_spares.
*  IF sy-subrc = 0.
*    COMMIT WORK.
*    WRITE: / 'Spare parts successfully inserted:', lines( lt_spares ).
*  ELSE.
*    WRITE: / 'Data insertion failed or duplicate keys found.'.
*  ENDIF.
REPORT zupload_jobs_spares.

DATA: lv_spare_id TYPE zjobs_spares-spare_id VALUE 'SP-106'.

UPDATE zjobs_spares
  SET stock_qty = 0
  WHERE spare_id = lv_spare_id.

IF sy-subrc = 0.
  WRITE: / 'Stock quantity updated to 0 for spare_id:', lv_spare_id.
ELSE.
  WRITE: / 'Spare ID not found:', lv_spare_id.
ENDIF.
