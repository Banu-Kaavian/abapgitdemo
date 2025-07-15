CLASS zcl_upload_jobs_hdr DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.   " Implement the interface to run as a program
    METHODS upload_csv_file.

ENDCLASS.

CLASS zcl_upload_jobs_hdr IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    " Entry point when running the class as a program
    me->upload_csv_file( ).
  ENDMETHOD.

  METHOD upload_csv_file.
    DATA: lt_jobs   TYPE TABLE OF zjobs_hdr,
          lv_file   TYPE string,
          lt_raw    TYPE STANDARD TABLE OF string,
          lv_line   TYPE string,
          lt_files  TYPE filetable,    " required for file_open_dialog
          lv_rc     TYPE i,            " return code from file_open_dialog
          lv_length TYPE i.

    " Open file dialog to select CSV file
    cl_gui_frontend_services=>file_open_dialog(
      EXPORTING
        file_filter = 'CSV (.csv)|.csv'
      CHANGING
        file_table  = lt_files
        rc          = lv_rc
      EXCEPTIONS
        OTHERS      = 1 ).

    " Check if user selected a file
    IF lv_rc <= 0.
      MESSAGE 'No file selected or dialog canceled.' TYPE 'I'.
      RETURN.
    ENDIF.

    " Get first selected file
    READ TABLE lt_files INDEX 1 INTO lv_file.

    " Upload the selected file contents into lt_raw table
    cl_gui_frontend_services=>gui_upload(
      EXPORTING
        filename            = lv_file
        filetype            = 'ASC'
        has_field_separator = abap_true
      IMPORTING
        filelength          = lv_length
      CHANGING
        data_tab            = lt_raw
      EXCEPTIONS
        OTHERS              = 1 ).

    " Process each line of the CSV data
    LOOP AT lt_raw INTO lv_line.
      SPLIT lv_line AT ',' INTO DATA(job_id) DATA(equip_id) DATA(status)
                                   DATA(fault_code) DATA(priority)
                                   DATA(assigned_to) DATA(job_date).

      APPEND VALUE zjobs_hdr( job_id      = job_id
                              equip_id    = equip_id
                              status      = status
                              fault_code  = fault_code
                              priority    = priority
                              assigned_to = assigned_to
                              job_date    = job_date
                              created_by  = sy-uname
                              created_on  = sy-datum ) TO lt_jobs.
    ENDLOOP.

    " Insert data into database table
    INSERT zjobs_hdr FROM TABLE lt_jobs.
    COMMIT WORK.

    MESSAGE |Uploaded { lines( lt_jobs ) } records successfully| TYPE 'S'.
  ENDMETHOD.

ENDCLASS.

