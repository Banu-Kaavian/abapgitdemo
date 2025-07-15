REPORT zupload_user_profile.

TABLES zuser_profile.

TYPES: BEGIN OF ty_user_profile,
         user_id TYPE zuser_profile-user_id,
         name    TYPE zuser_profile-name,
         role    TYPE zuser_profile-role,
         email   TYPE zuser_profile-email,
         phone   TYPE zuser_profile-phone,
       END OF ty_user_profile.

DATA: lt_users   TYPE TABLE OF ty_user_profile,
      lv_file    TYPE string,
      lt_raw     TYPE STANDARD TABLE OF string,
      lv_line    TYPE string,
      lt_files   TYPE filetable,
      lv_rc      TYPE i,
      lv_length  TYPE i.

START-OF-SELECTION.

  " File open dialog for CSV selection
  cl_gui_frontend_services=>file_open_dialog(
    EXPORTING
      file_filter = 'CSV Files (*.csv)|*.csv|'
    CHANGING
      file_table  = lt_files
      rc          = lv_rc
    EXCEPTIONS
      OTHERS      = 1 ).

  IF lv_rc <= 0 OR lines( lt_files ) = 0.
    WRITE: / 'No file selected or operation cancelled.'.
    RETURN.
  ENDIF.

  " Get filename from selected file
  READ TABLE lt_files INDEX 1 INTO lv_file.
  IF sy-subrc <> 0.
    WRITE: / 'File not found!'.
    RETURN.
  ENDIF.

  " Upload CSV file content
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

  " Loop over CSV lines starting from 2 to skip header
  LOOP AT lt_raw INTO lv_line FROM 2.

    DATA(ls_user) = VALUE ty_user_profile( ).

    " Split CSV line by comma into fields
    SPLIT lv_line AT ',' INTO
      ls_user-user_id
      ls_user-name
      ls_user-role
      ls_user-email
      ls_user-phone.

    " Append to internal table
    APPEND ls_user TO lt_users.

  ENDLOOP.

  " Insert all records into ZUSER_PROFILE
  INSERT zuser_profile FROM TABLE lt_users.
  IF sy-subrc = 0.
    COMMIT WORK.
    WRITE: / 'User profiles successfully inserted:', lines( lt_users ).
  ELSE.
    WRITE: / 'Data insertion failed or duplicate keys found.'.
  ENDIF.
