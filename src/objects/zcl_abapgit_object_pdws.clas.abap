CLASS zcl_abapgit_object_pdws DEFINITION
  PUBLIC
  INHERITING FROM zcl_abapgit_objects_super
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_abapgit_object.

    METHODS constructor IMPORTING is_item     TYPE zif_abapgit_definitions=>ty_item
                                  iv_language TYPE spras
                        RAISING   zcx_abapgit_exception.

  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS c_object_type_workflow TYPE hr_sotype VALUE 'WS'.

    DATA ms_objkey TYPE hrsobject.
    DATA mv_objid TYPE hrobjid.

    METHODS is_experimental RETURNING VALUE(rv_result) TYPE abap_bool.

ENDCLASS.



CLASS zcl_abapgit_object_pdws IMPLEMENTATION.

  METHOD constructor.

    super->constructor( is_item     = is_item
                        iv_language = iv_language ).

    IF is_experimental( ) = abap_false.
      "Work in progress
      zcx_abapgit_exception=>raise( 'PDWS is still work in progress, enable experimental features to test it' ).
    ENDIF.

    ms_objkey-otype = swfco_org_workflow_template.
    ms_objkey-objid = ms_item-obj_name.

  ENDMETHOD.

  METHOD zif_abapgit_object~changed_by.

    SELECT SINGLE uname
      INTO rv_user
      FROM hrs1201
      WHERE otype = c_object_type_workflow AND
            objid = ms_item-obj_name.

    IF sy-subrc <> 0.
      rv_user = c_user_unknown.
    ENDIF.

  ENDMETHOD.

  METHOD zif_abapgit_object~delete.

  ENDMETHOD.

  METHOD zif_abapgit_object~deserialize.

  ENDMETHOD.

  METHOD zif_abapgit_object~exists.

    CALL FUNCTION 'RH_READ_OBJECT'
      EXPORTING
        plvar     = '01'
        otype     = 'WS'
        objid     = mv_objid
        istat     = '1'
        begda     = sy-datum
        endda     = '99991231'
        ointerval = 'X'
        read_db   = 'X'
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.

    rv_bool = boolc( sy-subrc = 0 ).

  ENDMETHOD.

  METHOD zif_abapgit_object~get_comparator.
    RETURN.
  ENDMETHOD.

  METHOD zif_abapgit_object~get_deserialize_steps.
    APPEND zif_abapgit_object=>gc_step_id-abap TO rt_steps.
  ENDMETHOD.

  METHOD zif_abapgit_object~get_metadata.
    rs_metadata = get_metadata( ).
  ENDMETHOD.

  METHOD zif_abapgit_object~is_active.
    rv_active = abap_true.
  ENDMETHOD.

  METHOD zif_abapgit_object~is_locked.
    rv_is_locked = exists_a_lock_entry_for( iv_lock_object = 'HRSOBJECT'
                                            iv_argument = 'TS' && mv_objid ).
  ENDMETHOD.

  METHOD zif_abapgit_object~jump.

    CALL FUNCTION 'RS_TOOL_ACCESS_REMOTE'
      STARTING NEW TASK 'GIT'
      EXPORTING
        operation   = 'SHOW'
        object_name = ms_item-obj_name
        object_type = ms_item-obj_type
      EXCEPTIONS
        OTHERS      = 0.

  ENDMETHOD.

  METHOD zif_abapgit_object~serialize.

  ENDMETHOD.

  METHOD is_experimental.

    DATA lo_settings TYPE REF TO zcl_abapgit_settings.
    DATA lo_settings_persistence TYPE REF TO zcl_abapgit_persist_settings.

    lo_settings_persistence = zcl_abapgit_persist_settings=>get_instance( ).
    lo_settings = lo_settings_persistence->read( ).
    rv_result = lo_settings->get_experimental_features( ).

  ENDMETHOD.

ENDCLASS.
