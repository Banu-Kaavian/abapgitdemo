*&---------------------------------------------------------------------*
*& Report ZUPLOAD_JOBS_LOG
*&---------------------------------------------------------------------*
*& Uploads job logs from CSV. Matches date-handling logic used in ZUPLOAD_JOBS_CSV.
*&---------------------------------------------------------------------*
REPORT zupload_jobs_log.

TYPES: BEGIN OF ty_log,
         job_id          TYPE zjobs_log-job_id,
         log_seq         TYPE zjobs_log-log_seq,
         action_taken    TYPE zjobs_log-action_taken,
         time_spent_hrs  TYPE zjobs_log-time_spent_hrs,
         technician_note TYPE zjobs_log-technician_note,
         attachment_url  TYPE zjobs_log-attachment_url,
         created_by      TYPE zjobs_log-created_by,
         created_on      TYPE zjobs_log-created_on,
       END OF ty_log.

* Add display structure type definition
TYPES: BEGIN OF ty_display,
         created_on TYPE char10,  " For YYYY-MM-DD display format
       END OF ty_display.

DATA: lt_logs    TYPE TABLE OF ty_log,
      lv_file    TYPE string,
      lt_raw     TYPE STANDARD TABLE OF string,
      lv_line    TYPE string,
      lt_files   TYPE filetable,
      lv_rc      TYPE i,
      lv_length  TYPE i,
      lt_job_ids TYPE TABLE OF zjobs_log-job_id,
      lt_display TYPE TABLE OF ty_display,
      ls_display TYPE ty_display.

START-OF-SELECTION.

  " Select CSV file
  cl_gui_frontend_services=>file_open_dialog(
    EXPORTING
      file_filter = 'CSV Files (*.csv)|*.csv|'
    CHANGING
      file_table = lt_files
      rc = lv_rc
    EXCEPTIONS
      OTHERS = 1 ).

  IF lv_rc <= 0 OR lines( lt_files ) = 0.
    WRITE: / 'No file selected or operation canceled.'.
    RETURN.
  ENDIF.

  READ TABLE lt_files INDEX 1 INTO lv_file.

  " Upload file content to internal table
  cl_gui_frontend_services=>gui_upload(
    EXPORTING
      filename = lv_file
      filetype = 'ASC'
      has_field_separator = abap_true
    CHANGING
      data_tab = lt_raw
    EXCEPTIONS
      OTHERS = 1 ).

  IF sy-subrc <> 0.
    WRITE: / 'Error uploading file.'.
    RETURN.
  ENDIF.

  " Loop from line 2 to skip header
  LOOP AT lt_raw INTO lv_line FROM 2.

    DATA(ls_log) = VALUE ty_log( ).

    " Split CSV line fields (unchanged)
    SPLIT lv_line AT ',' INTO
      ls_log-job_id
      DATA(lv_log_seq)
      ls_log-action_taken
      DATA(lv_time_spent)
      ls_log-technician_note
      ls_log-attachment_url
      ls_log-created_by
      DATA(lv_created_on).

    " Convert numeric and date fields (unchanged except date)
    ls_log-log_seq = lv_log_seq.

    " Convert decimal (unchanged)
    REPLACE ALL OCCURRENCES OF ',' IN lv_time_spent WITH '.'.
    ls_log-time_spent_hrs = lv_time_spent.

    " >>> DATE HANDLING: Match ZUPLOAD_JOBS_CSV <<<
    REPLACE ALL OCCURRENCES OF '-' IN lv_created_on WITH ''.
    ls_log-created_on = lv_created_on.  " Stored as YYYYMMDD

    " Optional: prepare display format if needed
    IF strlen( lv_created_on ) = 8.
      ls_display-created_on = |{ lv_created_on+0(4) }-{ lv_created_on+4(2) }-{ lv_created_on+6(2) }|.
    ENDIF.

    " Append record to internal table
    APPEND ls_log TO lt_logs.
    APPEND ls_log-job_id TO lt_job_ids.

  ENDLOOP.

  " Remove duplicates from the list of JOB_IDs
  DELETE ADJACENT DUPLICATES FROM lt_job_ids.

  " Delete only the relevant JOB_IDs from the database
  LOOP AT lt_job_ids INTO DATA(lv_job_id).
    DELETE FROM zjobs_log WHERE job_id = lv_job_id.
  ENDLOOP.

  " Insert all data to database table
  INSERT zjobs_log FROM TABLE lt_logs.

  IF sy-subrc = 0.
    COMMIT WORK.
    WRITE: / 'Data successfully inserted:', lines( lt_logs ).
    IF ls_display-created_on IS NOT INITIAL.
      WRITE: / 'Sample display date format:', ls_display-created_on.
    ENDIF.
  ELSE.
    WRITE: / 'Data insertion failed.'.
  ENDIF.
