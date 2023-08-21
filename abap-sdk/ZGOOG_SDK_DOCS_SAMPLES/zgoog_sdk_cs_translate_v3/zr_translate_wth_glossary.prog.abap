*&---------------------------------------------------------------------*
*& Report ZR_TRANSLATE_WTH_GLOSSARY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zr_translate_wth_glossary.

* Data Declarations
DATA: lv_p_projects_id  TYPE string,
      lv_p_locations_id TYPE string,
      ls_input          TYPE /goog/cl_translation_v3=>ty_050,
      lo_exception      TYPE REF TO /goog/cx_sdk.

TRY.

*    Open HTTP Connection
    DATA(lo_translate) = NEW /goog/cl_translation_v3( iv_key_name = 'TRANSLATE_DEMO' ). "Pass the configured client key

*    Populate relevant entries
    lv_p_projects_id   = lo_translate->gv_project_id.  "Derive project id
    lv_p_locations_id  = 'us-central1'.                "Provide a location id, here 'us-central1' is uses as example
    ls_input-mime_type = 'text/plain'.                 "Provide MIME type

    ls_input-target_language_code = 'esES'.            "Target language code in BCP-47 format

    ls_input-glossary_config-glossary = 'fi_glossary_en_to_es'. "Provide glossary id

    ls_input-contents = VALUE #( ( |Debit amount carry forwarded for fiscal year| ) ).

*     Call the API
    CALL METHOD lo_translate->translate_text_locations
      EXPORTING
        iv_p_projects_id  = lv_p_projects_id
        iv_p_locations_id = lv_p_locations_id
        is_input          = ls_input
      IMPORTING
        es_output         = DATA(ls_output)
        ev_ret_code       = DATA(lv_ret_code)
        ev_err_text       = DATA(lv_err_text)
        es_err_resp       = DATA(ls_err_resp).
    IF /goog/cl_http_client=>is_success( lv_ret_code ).
*       On successfull call - print glossary translated text along with regular traslation
      READ TABLE ls_output-glossary_translations INTO DATA(ls_glss_translation) INDEX 1.
      IF sy-subrc EQ 0.
        WRITE: / 'Glossary Translated Text is: ', ls_glss_translation-translated_text.
      ENDIF.

      READ TABLE ls_output-translations INTO DATA(ls_translation) INDEX 1.
      IF sy-subrc EQ 0.
        WRITE: / 'Translated Text is: ', ls_translation-translated_text.
      ENDIF.
    ELSE.
      MESSAGE lv_err_text TYPE 'E'.
    ENDIF.

*     Close HTTP Connection
    lo_translate->close( ).

*   Handle exception
  CATCH /goog/cx_sdk INTO lo_exception.
    MESSAGE lo_exception->get_text( ) TYPE 'E'.
ENDTRY.
