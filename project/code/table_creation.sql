CREATE TABLE "SENSOR_TEST_DATA"
  (
    "RECORD_ID"            NUMBER,
    "EQP_NAME"             VARCHAR2(60 BYTE),
    "PART_NUMBER"          VARCHAR2(60 BYTE),
    "SERIAL_NUMBER"        VARCHAR2(60 BYTE),
    "INT_AMB_TEMP"         NUMBER,
    "EXT_AMB_TEMP"         NUMBER,
    "INPUT_CUR"            NUMBER,
    "INPUT_VOLT"           NUMBER,
    "VIB_X_AXIS"           NUMBER,
    "VIB_Y_AXIS"           NUMBER,
    "VIB_Z_AXIS"           NUMBER,
    "LABEL"                VARCHAR2(60 BYTE),
    "DATA_COLLECTION_TIME" TIMESTAMP (6),
    "CREATION_DATE"        DATE
  );
/

CREATE TABLE "SENSOR_TRAIN_DATA"
  (
    "EQP_NAME"      VARCHAR2(60 BYTE),
    "PART_NUMBER"   VARCHAR2(60 BYTE),
    "INT_AMB_TEMP"  NUMBER,
    "EXT_AMB_TEMP"  NUMBER,
    "INPUT_CUR"     NUMBER,
    "INPUT_VOLT"    NUMBER,
    "VIB_X_AXIS"    NUMBER,
    "VIB_Y_AXIS"    NUMBER,
    "VIB_Z_AXIS"    NUMBER,
    "LABEL"         VARCHAR2(60 BYTE),
    "CREATION_DATE" DATE
  );