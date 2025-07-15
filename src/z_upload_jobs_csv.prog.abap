REPORT z_upload_jobs_csv.

TABLES: zjobs_hdr.

TYPES: BEGIN OF ty_jobs,
         job_id      TYPE zjobs_hdr-job_id,
         equip_id    TYPE zjobs_hdr-equip_id,
         status      TYPE zjobs_hdr-status,
         fault_code  TYPE zjobs_hdr-fault_code,
         priority    TYPE zjobs_hdr-priority,
         assigned_to TYPE zjobs_hdr-assigned_to,
         job_date    TYPE zjobs_hdr-job_date,
         created_by  TYPE zjobs_hdr-created_by,
         created_on  TYPE zjobs_hdr-created_on,
       END OF ty_jobs.

DATA: lt_jobs     TYPE TABLE OF ty_jobs,
      lv_file     TYPE string,
      lt_raw      TYPE STANDARD TABLE OF string,
      lv_line     TYPE string,
      lt_files    TYPE filetable,
      lv_rc       TYPE i,
      lv_length   TYPE i.

START-OF-SELECTION.

  " --------------------------------------------------
  " STEP 1: Open File Dialog to choose CSV
  " --------------------------------------------------
  cl_gui_frontend_services=>file_open_dialog(
    EXPORTING
      file_filter = 'CSV Files (*.csv)|*.csv|'
    CHANGING
      file_table  = lt_files
      rc          = lv_rc
    EXCEPTIONS
      OTHERS      = 1 ).

  " Check if a file was selected
  IF lv_rc <= 0 OR lines( lt_files ) = 0.
    WRITE: / 'No file selected or operation canceled.'.
    RETURN.
  ENDIF.

  READ TABLE lt_files INDEX 1 INTO lv_file.
  IF sy-subrc <> 0.
    WRITE: / 'File not found!'.
    RETURN.
  ENDIF.

  " --------------------------------------------------
  " STEP 2: Upload CSV data into internal table
  " --------------------------------------------------
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

  IF sy-subrc <> 0.
    WRITE: / 'Error uploading file.'.
    RETURN.
  ENDIF.

  " --------------------------------------------------
  " STEP 3: Delete existing data from the database
  " --------------------------------------------------
  DELETE FROM zjobs_hdr.
  IF sy-subrc = 0.
    COMMIT WORK.
    WRITE: / 'Existing data deleted successfully.'.
  ELSE.
    WRITE: / 'Error while deleting existing data.'.
    RETURN.
  ENDIF.

  " --------------------------------------------------
  " STEP 4: Loop through each line and prepare data
  " --------------------------------------------------
  LOOP AT lt_raw INTO lv_line.
    " Skip header line (first row) if it is text
    IF lv_line CS 'JOB_ID'.
      CONTINUE.
    ENDIF.

    DATA(ls_job) = VALUE ty_jobs( ).

    " Split CSV line into individual fields
    SPLIT lv_line AT ',' INTO
      ls_job-job_id
      ls_job-equip_id
      ls_job-status
      ls_job-fault_code
      ls_job-priority
      ls_job-assigned_to
      DATA(lv_job_date)
      ls_job-created_by
      DATA(lv_created_on).

    " Remove hyphens from date formats
    REPLACE ALL OCCURRENCES OF '-' IN lv_job_date WITH ''.
    REPLACE ALL OCCURRENCES OF '-' IN lv_created_on WITH ''.

    " Assign formatted dates
    ls_job-job_date = lv_job_date.
    ls_job-created_on = lv_created_on.

    " Append to final table for insertion
    APPEND ls_job TO lt_jobs.
  ENDLOOP.

  " --------------------------------------------------
  " STEP 5: Insert the records into the database table
  " --------------------------------------------------
  INSERT zjobs_hdr FROM TABLE lt_jobs.
  IF sy-subrc = 0.
    COMMIT WORK.
    WRITE: / 'Data successfully inserted: ', lines( lt_jobs ).
  ELSE.
    WRITE: / 'Data insertion failed.'.
  ENDIF.
